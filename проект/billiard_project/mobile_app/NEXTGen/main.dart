import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const YourMomApp());
}

// ============ API КОНСТАНТЫ ============
class ApiConstants {
  static const String baseUrl =
      'https://ваш_домен.bitrix24.ru/rest/1/ваш_вебхук/';
  static const String createLead = 'crm.lead.add';
  static const String createDeal = 'crm.deal.add';
  static const String createContact = 'crm.contact.add';
  static const String createActivity = 'crm.activity.add';
}

// ============ МОДЕЛИ ДАННЫХ ============
class BookingModel {
  final int tableNumber;
  final String customerName;
  final String phone;
  final DateTime bookingTime;
  final String? additionalNotes;

  BookingModel({
    required this.tableNumber,
    required this.customerName,
    required this.phone,
    required this.bookingTime,
    this.additionalNotes,
  });

  Map<String, dynamic> toJson() => {
        'tableNumber': tableNumber,
        'customerName': customerName,
        'phone': phone,
        'bookingTime': bookingTime.toIso8601String(),
        'additionalNotes': additionalNotes,
      };
}

// ============ МОДЕЛЬ ОТЗЫВА ============
class ReviewModel {
  final String userName;
  final int tableId;
  final String tableName;
  final double rating;
  final String text;
  final DateTime date;

  ReviewModel({
    required this.userName,
    required this.tableId,
    required this.tableName,
    required this.rating,
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'tableId': tableId,
        'tableName': tableName,
        'rating': rating,
        'text': text,
        'date': date.toIso8601String(),
      };

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        userName: json['userName'],
        tableId: json['tableId'],
        tableName: json['tableName'],
        rating: json['rating'],
        text: json['text'],
        date: DateTime.parse(json['date']),
      );
}

// ============ СЕРВИС БИТРИКС24 ============
class BitrixService {
  Future<Map<String, dynamic>> createBookingLead(BookingModel booking) async {
    final Map<String, dynamic> leadData = {
      'fields': {
        'TITLE': 'Бронь стола №${booking.tableNumber}',
        'NAME': booking.customerName,
        'PHONE': [
          {
            'VALUE': booking.phone,
            'VALUE_TYPE': 'WORK',
          }
        ],
        'COMMENTS': '''
Бронирование бильярдного стола
Стол: №${booking.tableNumber}
Время: ${booking.bookingTime.toLocal().toString()}
Дополнительно: ${booking.additionalNotes ?? 'Нет'}
''',
        'SOURCE_ID': 'WEB',
        'STATUS_ID': 'NEW',
      }
    };

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createLead}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(leadData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<Map<String, dynamic>> createOrderDeal(
    String customerName,
    String phone,
    List<Map<String, dynamic>> items,
    double totalAmount,
  ) async {
    final String itemsString = items
        .map((item) =>
            '- ${item['name']} x${item['quantity']}: ${(item['price'] as int) * (item['quantity'] as int)} ₽')
        .join('\n');

    final Map<String, dynamic> dealData = {
      'fields': {
        'TITLE': 'Заказ еды для клиента: $customerName',
        'OPPORTUNITY': totalAmount,
        'COMMENTS': '''
Заказ еды:
$itemsString
Телефон: $phone
Общая сумма: $totalAmount ₽
''',
        'SOURCE_ID': 'WEB',
        'STAGE_ID': 'NEW',
      }
    };

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createDeal}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(dealData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<Map<String, dynamic>> createReview(
    String customerName,
    double rating,
    String text,
  ) async {
    final Map<String, dynamic> activityData = {
      'fields': {
        'SUBJECT': 'Отзыв клиента: $customerName',
        'DESCRIPTION': '''
Оценка: $rating / 5
Отзыв: $text
Дата: ${DateTime.now().toLocal().toString()}
''',
        'TYPE_ID': 'NOTE',
        'PRIORITY': 'HIGH',
      }
    };

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createActivity}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(activityData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }
}

// ============ КЭШ СЕРВИС ============
class CacheService {
  static const String _lastBookingKey = 'last_booking';
  static const String _cartKey = 'cart_data';
  static const String _profileKey = 'profile_data';
  static const String _reviewsKey = 'reviews_data';

  static Future<void> saveLastBooking(BookingModel booking) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBookingKey, jsonEncode(booking.toJson()));
  }

  static Future<Map<String, dynamic>?> getLastBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_lastBookingKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  static Future<void> saveCart(Map<int, int> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString =
        jsonEncode(cart.map((key, value) => MapEntry(key.toString(), value)));
    await prefs.setString(_cartKey, jsonString);
  }

  static Future<Map<int, int>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_cartKey);
    if (data != null) {
      final Map<String, dynamic> decoded = jsonDecode(data);
      return decoded
          .map((key, value) => MapEntry(int.parse(key), value as int));
    }
    return {};
  }

  static Future<void> saveProfile(Map<String, String> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile));
  }

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_profileKey);
    if (data != null) {
      final Map<String, dynamic> decoded = jsonDecode(data);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }

  static Future<void> saveReviews(List<ReviewModel> reviews) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        reviews.map((r) => r.toJson()).toList();
    await prefs.setString(_reviewsKey, jsonEncode(jsonList));
  }

  static Future<List<ReviewModel>> getReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_reviewsKey);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => ReviewModel.fromJson(json)).toList();
    }
    return [];
  }
}

// ============ УТИЛИТЫ ============
class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }
    String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 10) {
      return 'Введите 10 цифр после +7 (например, 9991234567)';
    }
    return null;
  }

  static String formatFullName(String value) {
    if (value.isEmpty) return value;
    return value.split(' ').map((word) {
      if (word.isEmpty) return word;
      word = word.trim();
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static String cleanPhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String formatPhoneForDisplay(String value) {
    String cleaned = cleanPhone(value);
    if (cleaned.isEmpty) return '';
    if (cleaned.length == 10) {
      return '+7 ${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)}-${cleaned.substring(6, 8)}-${cleaned.substring(8, 10)}';
    }
    return cleaned;
  }

  static String getCleanPhoneForCRM(String value) {
    String cleaned = cleanPhone(value);
    if (cleaned.isEmpty) return '';
    if (cleaned.length == 10) {
      return '+7$cleaned';
    }
    return cleaned;
  }
}

// ============ НОТИФАЙЕР ============
class ReviewNotifier {
  static final ReviewNotifier _instance = ReviewNotifier._internal();
  factory ReviewNotifier() => _instance;
  ReviewNotifier._internal();

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notify() {
    for (var listener in _listeners) {
      listener();
    }
  }
}

// ============ ГЛАВНОЕ ПРИЛОЖЕНИЕ ============
class YourMomApp extends StatelessWidget {
  const YourMomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billiard Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xff2E7D32),
        scaffoldBackgroundColor: const Color(0xffF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xff2E7D32),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xff2E7D32),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xff212121)),
          bodyMedium: TextStyle(color: Color(0xff757575)),
        ),
        dialogBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff2E7D32), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffE53935)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// ============ ГЛАВНЫЙ ЭКРАН ============
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BookingTab(),
    const FoodTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎱 Бильярдный Клуб'),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications_none, color: Color(0xff2E7D32)),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xff2E7D32),
        unselectedItemColor: const Color(0xffBDBDBD),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.table_bar),
            label: 'Бронь',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Еда',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

// ============ ВКЛАДКА 1: БРОНИРОВАНИЕ ============
class BookingTab extends StatefulWidget {
  const BookingTab({super.key});

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab> {
  List<Map<String, dynamic>> tables = [
    {
      'id': 1,
      'name': 'Стол №1',
      'status': 'Свободен',
      'statusColor': const Color(0xff4CAF50),
      'price': '500 ₽/час',
      'location': 'VIP зал',
      'rating': 0.0,
      'reviews': 0,
      'size': '12 футов',
      'material': 'Китайский сукно',
      'balls': 'Профессиональные',
      'cues': 'В комплекте',
      'reviewList': []
    },
    {
      'id': 2,
      'name': 'Стол №2',
      'status': 'Занят',
      'statusColor': const Color(0xffE53935),
      'price': '500 ₽/час',
      'location': 'VIP зал',
      'rating': 0.0,
      'reviews': 0,
      'size': '12 футов',
      'material': 'Китайский сукно',
      'balls': 'Профессиональные',
      'cues': 'В комплекте',
      'reviewList': []
    },
    {
      'id': 3,
      'name': 'Стол №3',
      'status': 'Свободен',
      'statusColor': const Color(0xff4CAF50),
      'price': '400 ₽/час',
      'location': 'Основной зал',
      'rating': 0.0,
      'reviews': 0,
      'size': '10 футов',
      'material': 'Стандартный сукно',
      'balls': 'Любительские',
      'cues': 'В комплекте',
      'reviewList': []
    },
    {
      'id': 4,
      'name': 'Стол №4',
      'status': 'Свободен',
      'statusColor': const Color(0xff4CAF50),
      'price': '400 ₽/час',
      'location': 'Основной зал',
      'rating': 0.0,
      'reviews': 0,
      'size': '10 футов',
      'material': 'Стандартный сукно',
      'balls': 'Любительские',
      'cues': 'В комплекте',
      'reviewList': []
    },
    {
      'id': 5,
      'name': 'Стол №5',
      'status': 'Свободен',
      'statusColor': const Color(0xff4CAF50),
      'price': '350 ₽/час',
      'location': 'Общий зал',
      'rating': 0.0,
      'reviews': 0,
      'size': '9 футов',
      'material': 'Стандартный сукно',
      'balls': 'Любительские',
      'cues': 'В комплекте',
      'reviewList': []
    },
    {
      'id': 6,
      'name': 'Стол №6',
      'status': 'Занят',
      'statusColor': const Color(0xffE53935),
      'price': '350 ₽/час',
      'location': 'Общий зал',
      'rating': 0.0,
      'reviews': 0,
      'size': '9 футов',
      'material': 'Стандартный сукно',
      'balls': 'Любительские',
      'cues': 'В комплекте',
      'reviewList': []
    },
    {
      'id': 7,
      'name': 'Стол №7',
      'status': 'Свободен',
      'statusColor': const Color(0xff4CAF50),
      'price': '300 ₽/час',
      'location': 'Общий зал',
      'rating': 0.0,
      'reviews': 0,
      'size': '8 футов',
      'material': 'Стандартный сукно',
      'balls': 'Любительские',
      'cues': 'В комплекте',
      'reviewList': []
    },
    {
      'id': 8,
      'name': 'Стол №8',
      'status': 'Свободен',
      'statusColor': const Color(0xff4CAF50),
      'price': '300 ₽/час',
      'location': 'Общий зал',
      'rating': 0.0,
      'reviews': 0,
      'size': '8 футов',
      'material': 'Стандартный сукно',
      'balls': 'Любительские',
      'cues': 'В комплекте',
      'reviewList': []
    },
  ];

  String _searchQuery = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadReviews();
    ReviewNotifier().addListener(_onReviewsUpdated);
  }

  @override
  void dispose() {
    ReviewNotifier().removeListener(_onReviewsUpdated);
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onReviewsUpdated() {
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final savedReviews = await CacheService.getReviews();
    setState(() {
      for (var table in tables) {
        final tableReviews =
            savedReviews.where((r) => r.tableId == table['id']).toList();
        table['reviewList'] = tableReviews;
        if (tableReviews.isNotEmpty) {
          final totalRating =
              tableReviews.fold(0.0, (sum, r) => sum + r.rating);
          table['rating'] = (totalRating / tableReviews.length);
          table['reviews'] = tableReviews.length;
        } else {
          table['rating'] = 0.0;
          table['reviews'] = 0;
        }
      }
    });
  }

  List<Map<String, dynamic>> get _filteredTables {
    if (_searchQuery.isEmpty) return tables;
    return tables
        .where((table) =>
            table['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            table['location']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _showTableDialog(Map<String, dynamic> table) {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _nameController.clear();
      _phoneController.clear();
      _notesController.clear();
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('🎱 ${table['name']}',
                style: const TextStyle(
                    color: Color(0xff212121),
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xffE8F5E9),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      const Text('🎱', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(table['name'],
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff212121))),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: table['statusColor'],
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(table['status'],
                              style: TextStyle(
                                  color: table['statusColor'],
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(table['location'],
                          style: const TextStyle(
                              color: Color(0xff757575), fontSize: 14)),
                      if (table['reviews'] > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                color: Color(0xffFFB300), size: 16),
                            const SizedBox(width: 4),
                            Text(
                                '${(table['rating'] as double).toStringAsFixed(1)} (${table['reviews']} отзывов)',
                                style: const TextStyle(
                                    color: Color(0xff757575),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        const Text('Нет отзывов',
                            style: TextStyle(
                                color: Color(0xffBDBDBD), fontSize: 14)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('📋 Характеристики:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff212121),
                        fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      _buildInfoRow('📏 Размер', table['size']),
                      _buildInfoRow('🧵 Материал', table['material']),
                      _buildInfoRow('⚪ Шары', table['balls']),
                      _buildInfoRow('🎱 Кии', table['cues']),
                      _buildInfoRow('💰 Стоимость', table['price']),
                    ],
                  ),
                ),
                if ((table['reviewList'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('💬 Отзывы:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff212121),
                          fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xffF5F5F5),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: (table['reviewList'] as List<ReviewModel>)
                          .map((review) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(review.userName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff212121),
                                                fontSize: 14)),
                                        const SizedBox(width: 8),
                                        Text('⭐' * review.rating.round(),
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    Text(review.text,
                                        style: const TextStyle(
                                            color: Color(0xff757575),
                                            fontSize: 13)),
                                    Text(
                                        review.date
                                            .toLocal()
                                            .toString()
                                            .substring(0, 16),
                                        style: const TextStyle(
                                            color: Color(0xffBDBDBD),
                                            fontSize: 11)),
                                    const Divider(height: 8),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('📅 Выберите дату и время:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff212121),
                        fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 30)));
                          if (date != null)
                            setState(() => _selectedDate = date);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xffE0E0E0)),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Color(0xff2E7D32), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                  _selectedDate == null
                                      ? 'Выберите дату'
                                      : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                                  style: TextStyle(
                                      color: _selectedDate == null
                                          ? const Color(0xff757575)
                                          : const Color(0xff212121))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                              context: context,
                              initialTime:
                                  const TimeOfDay(hour: 19, minute: 0));
                          if (time != null)
                            setState(() => _selectedTime = time);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xffE0E0E0)),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: Color(0xff2E7D32), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                  _selectedTime == null
                                      ? 'Выберите время'
                                      : _selectedTime!.format(context),
                                  style: TextStyle(
                                      color: _selectedTime == null
                                          ? const Color(0xff757575)
                                          : const Color(0xff212121))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Контактные данные:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff212121),
                        fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Color(0xff212121)),
                  decoration: const InputDecoration(
                      labelText: 'Ваше имя *',
                      labelStyle: TextStyle(color: Color(0xff757575)),
                      hintText: 'Иванов Иван Иванович',
                      hintStyle: TextStyle(color: Color(0xffBDBDBD))),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final formatted = Validators.formatFullName(value);
                      if (formatted != value) {
                        _nameController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                                offset: formatted.length));
                      }
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Введите ваше ФИО';
                    if (value.split(' ').length < 2)
                      return 'Введите полное ФИО (Имя и Фамилию)';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: Color(0xff212121)),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                  decoration: const InputDecoration(
                      labelText: 'Телефон *',
                      labelStyle: TextStyle(color: Color(0xff757575)),
                      hintText: '999 123-45-67',
                      hintStyle: TextStyle(color: Color(0xffBDBDBD)),
                      prefixText: '+7 ',
                      counterText: ''),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (cleaned.length > 10)
                        cleaned = cleaned.substring(0, 10);
                      String formatted = '';
                      for (int i = 0; i < cleaned.length; i++) {
                        if (i == 0)
                          formatted += cleaned[i];
                        else if (i == 3)
                          formatted += ' ${cleaned[i]}';
                        else if (i == 6)
                          formatted += ' ${cleaned[i]}';
                        else if (i == 8)
                          formatted += '-${cleaned[i]}';
                        else
                          formatted += cleaned[i];
                      }
                      if (formatted != value) {
                        _phoneController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                                offset: formatted.length));
                      }
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Введите номер телефона';
                    String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cleaned.length != 10)
                      return 'Введите 10 цифр (например, 9991234567)';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  style: const TextStyle(color: Color(0xff212121)),
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Дополнительные пожелания',
                      labelStyle: TextStyle(color: Color(0xff757575)),
                      hintText: 'Особые пожелания к брони...',
                      hintStyle: TextStyle(color: Color(0xffBDBDBD))),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена',
                  style: TextStyle(color: Color(0xff757575)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2E7D32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              if (_selectedDate == null || _selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Выберите дату и время'),
                    backgroundColor: Colors.red));
                return;
              }
              Navigator.pop(context);
              final formattedName =
                  Validators.formatFullName(_nameController.text);
              final phoneDisplay = _phoneController.text;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '✅ Бронь стола ${table['name']} создана!\n$formattedName\n+7 $phoneDisplay'),
                  backgroundColor: const Color(0xff4CAF50),
                  duration: const Duration(seconds: 3)));
            },
            child: const Text('✅ Забронировать',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xff757575), fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: Color(0xff212121),
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: Color(0xff212121)),
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: '🔍 Поиск стола...',
              hintStyle: const TextStyle(color: Color(0xff757575)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🎱 Все столы (${_filteredTables.length})',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff212121))),
              if (_searchQuery.isNotEmpty)
                TextButton(
                    onPressed: () => setState(() => _searchQuery = ''),
                    child: const Text('Сбросить',
                        style: TextStyle(color: Color(0xff2E7D32)))),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85),
              itemCount: _filteredTables.length,
              itemBuilder: (context, index) {
                final table = _filteredTables[index];
                return _TableCard(
                  table: table,
                  onTap: () => _showTableDialog(table),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ============ КАРТОЧКА СТОЛА ============
class _TableCard extends StatelessWidget {
  final Map<String, dynamic> table;
  final VoidCallback onTap;

  const _TableCard({
    required this.table,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasReviews = table['reviews'] > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎱', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 4),
              Text(table['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xff212121))),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (table['statusColor'] == const Color(0xff4CAF50))
                      ? const Color(0xffE8F5E9)
                      : const Color(0xffFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(table['status'],
                    style: TextStyle(
                        color: table['statusColor'],
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              Text(table['price'],
                  style: const TextStyle(
                      color: Color(0xff2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 2),
              if (hasReviews) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Color(0xffFFB300), size: 14),
                    const SizedBox(width: 2),
                    Text((table['rating'] as double).toStringAsFixed(1),
                        style: const TextStyle(
                            color: Color(0xff757575), fontSize: 12)),
                    const SizedBox(width: 2),
                    Text('(${table['reviews']})',
                        style: const TextStyle(
                            color: Color(0xffBDBDBD), fontSize: 10)),
                  ],
                ),
              ] else ...[
                const Text('Нет отзывов',
                    style: TextStyle(color: Color(0xffBDBDBD), fontSize: 11)),
              ],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xffF5F5F5),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(table['location'],
                    style: const TextStyle(
                        color: Color(0xff757575), fontSize: 10)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ ВКЛАДКА 2: ЕДА И НАПИТКИ ============
class FoodTab extends StatefulWidget {
  const FoodTab({super.key});

  @override
  State<FoodTab> createState() => _FoodTabState();
}

class _FoodTabState extends State<FoodTab> {
  final List<Map<String, dynamic>> menu = const [
    {'name': 'Бургер Фирменный', 'price': 450, 'icon': '🍔', 'id': 1},
    {'name': 'Картофель фри', 'price': 180, 'icon': '🍟', 'id': 2},
    {'name': 'Кола 0.5', 'price': 120, 'icon': '🥤', 'id': 3},
    {'name': 'Салат Цезарь', 'price': 350, 'icon': '🥗', 'id': 4},
    {'name': 'Пицца Маргарита', 'price': 520, 'icon': '🍕', 'id': 5},
    {'name': 'Морс клюквенный', 'price': 150, 'icon': '🧃', 'id': 6},
  ];

  Map<int, int> _cart = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final savedCart = await CacheService.getCart();
    setState(() {
      _cart = savedCart;
    });
  }

  Future<void> _saveCart() async {
    await CacheService.saveCart(_cart);
  }

  double get _totalAmount {
    double total = 0;
    _cart.forEach((id, quantity) {
      final item = menu.firstWhere((item) => item['id'] == id);
      total += (item['price'] as int) * quantity;
    });
    return total;
  }

  int get _totalItems => _cart.values.fold(0, (sum, qty) => sum + qty);

  void _addToCart(int id) {
    setState(() {
      _cart[id] = (_cart[id] ?? 0) + 1;
    });
    _saveCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${menu.firstWhere((item) => item['id'] == id)['name']} добавлен в корзину'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xff4CAF50),
      ),
    );
  }

  void _removeFromCart(int id) {
    setState(() {
      if (_cart.containsKey(id)) {
        if (_cart[id] == 1) {
          _cart.remove(id);
        } else {
          _cart[id] = _cart[id]! - 1;
        }
      }
    });
    _saveCart();
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
    _saveCart();
  }

  void _showCheckoutDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🛒 Оформление заказа',
            style: TextStyle(color: Color(0xff212121), fontSize: 20)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                style: const TextStyle(color: Color(0xff212121)),
                decoration: const InputDecoration(
                    labelText: 'Ваше имя *',
                    labelStyle: TextStyle(color: Color(0xff757575)),
                    hintText: 'Иванов Иван Иванович',
                    hintStyle: TextStyle(color: Color(0xffBDBDBD))),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final formatted = Validators.formatFullName(value);
                    if (formatted != value) {
                      nameController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                              offset: formatted.length));
                    }
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите ваше ФИО';
                  if (value.split(' ').length < 2)
                    return 'Введите полное ФИО (Имя и Фамилию)';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                style: const TextStyle(color: Color(0xff212121)),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
                decoration: const InputDecoration(
                    labelText: 'Телефон *',
                    labelStyle: TextStyle(color: Color(0xff757575)),
                    hintText: '999 123-45-67',
                    hintStyle: TextStyle(color: Color(0xffBDBDBD)),
                    prefixText: '+7 ',
                    counterText: ''),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cleaned.length > 10) cleaned = cleaned.substring(0, 10);
                    String formatted = '';
                    for (int i = 0; i < cleaned.length; i++) {
                      if (i == 0)
                        formatted += cleaned[i];
                      else if (i == 3)
                        formatted += ' ${cleaned[i]}';
                      else if (i == 6)
                        formatted += ' ${cleaned[i]}';
                      else if (i == 8)
                        formatted += '-${cleaned[i]}';
                      else
                        formatted += cleaned[i];
                    }
                    if (formatted != value) {
                      phoneController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                              offset: formatted.length));
                    }
                  }
                },
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xffE8F5E9),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Итого:',
                        style:
                            TextStyle(color: Color(0xff212121), fontSize: 16)),
                    Text('$_totalAmount ₽',
                        style: const TextStyle(
                            color: Color(0xff2E7D32),
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Товаров в корзине: $_totalItems шт.',
                  style: const TextStyle(color: Color(0xff757575))),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена',
                  style: TextStyle(color: Color(0xff757575)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2E7D32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              setState(() => _isLoading = true);
              final orderItems = _cart.entries.map((entry) {
                final item = menu.firstWhere((item) => item['id'] == entry.key);
                return {
                  'name': item['name'],
                  'price': item['price'],
                  'quantity': entry.value
                };
              }).toList();
              final bitrixService = BitrixService();
              try {
                final result = await bitrixService.createOrderDeal(
                    nameController.text,
                    phoneController.text,
                    orderItems,
                    _totalAmount);
                if (result.containsKey('result')) {
                  if (context.mounted) Navigator.pop(context);
                  _clearCart();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('✅ Заказ успешно отправлен!'),
                        backgroundColor: Color(0xff4CAF50)));
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('❌ Ошибка: $e'),
                      backgroundColor: Colors.red));
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Оформить заказ',
                    style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_totalItems > 0)
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xffE8F5E9),
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart, color: Color(0xff2E7D32)),
                    const SizedBox(width: 8),
                    Text('$_totalItems шт.',
                        style: const TextStyle(color: Color(0xff212121))),
                  ],
                ),
                Text('$_totalAmount ₽',
                    style: const TextStyle(
                        color: Color(0xff2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: _clearCart,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints()),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2E7D32),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8)),
                      onPressed: _showCheckoutDialog,
                      child: const Text('Оформить',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: menu.length,
            itemBuilder: (context, index) {
              final item = menu[index];
              final quantity = _cart[item['id']] ?? 0;
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Text(item['icon'],
                        style: const TextStyle(fontSize: 32)),
                    title: Text(item['name'],
                        style: const TextStyle(
                            color: Color(0xff212121),
                            fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['price']} ₽',
                        style: const TextStyle(color: Color(0xff2E7D32))),
                    trailing: quantity > 0
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.remove,
                                      color: Color(0xff757575), size: 20),
                                  onPressed: () => _removeFromCart(item['id']),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints()),
                              Container(
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: Text('$quantity',
                                      style: const TextStyle(
                                          color: Color(0xff212121),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                              IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Color(0xff2E7D32), size: 20),
                                  onPressed: () => _addToCart(item['id']),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints()),
                            ],
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2E7D32),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8)),
                            onPressed: () => _addToCart(item['id']),
                            child: const Text('Добавить',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============ ВКЛАДКА 3: ПРОФИЛЬ ============
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _reviewTextController = TextEditingController();
  double _rating = 5.0;
  bool _isEditing = false;
  int? _selectedTableId;
  String _selectedTableName = 'Выберите стол';

  final List<Map<String, dynamic>> _history = [
    {'table': 'Стол №1', 'date': '23.06.2026', 'status': '✅ Готово'},
    {'table': 'Стол №3', 'date': '20.06.2026', 'status': '✅ Готово'},
    {'table': 'Стол №5', 'date': '15.06.2026', 'status': '✅ Готово'},
  ];

  final List<Map<String, dynamic>> tables = [
    {'id': 1, 'name': 'Стол №1'},
    {'id': 2, 'name': 'Стол №2'},
    {'id': 3, 'name': 'Стол №3'},
    {'id': 4, 'name': 'Стол №4'},
    {'id': 5, 'name': 'Стол №5'},
    {'id': 6, 'name': 'Стол №6'},
    {'id': 7, 'name': 'Стол №7'},
    {'id': 8, 'name': 'Стол №8'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await CacheService.getProfile();
    setState(() {
      _nameController.text = profile['name'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _emailController.text = profile['email'] ?? '';
      _cityController.text = profile['city'] ?? '';
    });
  }

  Future<void> _saveProfile() async {
    final phone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isNotEmpty && phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Введите корректный номер телефона (10 цифр)'),
            backgroundColor: Colors.red),
      );
      return;
    }
    final formattedName = Validators.formatFullName(_nameController.text);
    _nameController.text = formattedName;
    await CacheService.saveProfile({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'city': _cityController.text,
    });
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('✅ Профиль сохранен!'),
          backgroundColor: Color(0xff4CAF50)),
    );
  }

  Future<void> _submitReview() async {
    if (_selectedTableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Выберите стол для отзыва'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_reviewTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Напишите текст отзыва'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final userName =
        _nameController.text.isEmpty ? 'Гость' : _nameController.text;
    final newReview = ReviewModel(
      userName: userName,
      tableId: _selectedTableId!,
      tableName: _selectedTableName,
      rating: _rating,
      text: _reviewTextController.text,
      date: DateTime.now(),
    );

    final existingReviews = await CacheService.getReviews();
    existingReviews.add(newReview);
    await CacheService.saveReviews(existingReviews);

    setState(() {
      _reviewTextController.clear();
      _rating = 5.0;
      _selectedTableId = null;
      _selectedTableName = 'Выберите стол';
    });

    ReviewNotifier().notify();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('✅ Отзыв успешно добавлен!'),
          backgroundColor: Color(0xff4CAF50)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xff2E7D32), Color(0xff4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.person,
                        size: 40, color: Color(0xff2E7D32))),
                const SizedBox(height: 8),
                Text(
                    _nameController.text.isEmpty
                        ? 'Гость'
                        : _nameController.text,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text(
                    _phoneController.text.isEmpty
                        ? 'Не указан'
                        : '+7 ${_phoneController.text}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📋 Мои данные',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff212121))),
              TextButton(
                onPressed: () {
                  if (_isEditing) {
                    _saveProfile();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                child: Text(_isEditing ? '💾 Сохранить' : '✏️ Редактировать',
                    style: const TextStyle(color: Color(0xff2E7D32))),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4)
                ]),
            child: Column(
              children: [
                _buildProfileField('👤 ФИО', _nameController, _isEditing),
                _buildProfileField('📱 Телефон', _phoneController, _isEditing,
                    isPhone: true),
                _buildProfileField('✉️ Email', _emailController, _isEditing),
                _buildProfileField('📍 Город', _cityController, _isEditing),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('📖 История бронирований',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff212121))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4)
                ]),
            child: Column(
              children: _history
                  .map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('🎱 ${item['table']}',
                                style: const TextStyle(
                                    color: Color(0xff212121),
                                    fontWeight: FontWeight.w500)),
                            Text(item['date'],
                                style:
                                    const TextStyle(color: Color(0xff757575))),
                            Text(item['status'],
                                style:
                                    const TextStyle(color: Color(0xff4CAF50))),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('⭐ Оставить отзыв о столе',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff212121))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4)
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Выберите стол:',
                    style: TextStyle(
                        color: Color(0xff212121),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffE0E0E0)),
                      borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedTableId,
                      hint: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(_selectedTableName,
                            style: const TextStyle(color: Color(0xff757575))),
                      ),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      items: tables.map((table) {
                        return DropdownMenuItem<int>(
                          value: table['id'],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(table['name'],
                                style:
                                    const TextStyle(color: Color(0xff212121))),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTableId = value;
                          _selectedTableName = tables
                              .firstWhere((t) => t['id'] == value)['name'];
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Оценка:',
                        style: TextStyle(color: Color(0xff212121))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        value: _rating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _rating.round().toString(),
                        activeColor: const Color(0xff2E7D32),
                        inactiveColor: const Color(0xffBDBDBD),
                        onChanged: (value) => setState(() => _rating = value),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: const Color(0xffE8F5E9),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text('${_rating.round()} ★',
                          style: const TextStyle(
                              color: Color(0xff2E7D32),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reviewTextController,
                  maxLines: 3,
                  style: const TextStyle(color: Color(0xff212121)),
                  decoration: InputDecoration(
                    hintText: 'Напишите ваши впечатления о столе...',
                    hintStyle: const TextStyle(color: Color(0xff757575)),
                    filled: true,
                    fillColor: const Color(0xffF5F5F5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2E7D32),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: _submitReview,
                    child: const Text('📤 Отправить отзыв',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfileField(
      String label, TextEditingController controller, bool isEditing,
      {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(color: Color(0xff757575), fontSize: 14)),
          ),
          Expanded(
            child: isEditing
                ? isPhone
                    ? TextFormField(
                        controller: controller,
                        style: const TextStyle(color: Color(0xff212121)),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10)
                        ],
                        decoration: const InputDecoration(
                          isDense: true,
                          prefixText: '+7 ',
                          counterText: '',
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffE0E0E0))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff2E7D32))),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            String cleaned =
                                value.replaceAll(RegExp(r'[^0-9]'), '');
                            if (cleaned.length > 10)
                              cleaned = cleaned.substring(0, 10);
                            String formatted = '';
                            for (int i = 0; i < cleaned.length; i++) {
                              if (i == 0)
                                formatted += cleaned[i];
                              else if (i == 3)
                                formatted += ' ${cleaned[i]}';
                              else if (i == 6)
                                formatted += ' ${cleaned[i]}';
                              else if (i == 8)
                                formatted += '-${cleaned[i]}';
                              else
                                formatted += cleaned[i];
                            }
                            if (formatted != value) {
                              controller.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(
                                      offset: formatted.length));
                            }
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Введите номер';
                          String cleaned =
                              value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (cleaned.length != 10) return 'Введите 10 цифр';
                          return null;
                        },
                      )
                    : TextField(
                        controller: controller,
                        style: const TextStyle(color: Color(0xff212121)),
                        decoration: const InputDecoration(
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffE0E0E0))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff2E7D32))),
                        ),
                      )
                : Text(
                    isPhone && controller.text.isNotEmpty
                        ? '+7 ${controller.text}'
                        : (controller.text.isEmpty
                            ? 'Не указано'
                            : controller.text),
                    style: const TextStyle(color: Color(0xff212121)),
                  ),
          ),
        ],
      ),
    );
  }
}
