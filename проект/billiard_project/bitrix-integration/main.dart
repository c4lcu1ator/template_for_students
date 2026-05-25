import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const YourMomApp());
}

class BitrixService {
  final Dio _dio = Dio();
  final String demoDomain = 'billiard-club.bitrix24.ru';
  final String demoToken = 'example_oauth_access_token_from_database';

  Future<bool> createBooking({
    required String clientName,
    required String phone,
    required int tableNumber,
    required List<Map<String, dynamic>> foodItems,
  }) async {
    final String url = 'https://$demoDomain/rest/crm.deal.add.json';
    try {
      final response = await _dio.post(
        url,
        data: {
          'auth': demoToken,
          'fields': {
            'TITLE': 'Бронь стола №$tableNumber: $clientName',
            'CATEGORY_ID': 0,
            'COMMENTS': 'Телефон: $phone. Еда: ${foodItems.toString()}',
            'UF_CRM_TABLE_NUM': tableNumber,
          },
          'params': {'REGISTER_SONET_EVENT': 'Y'}
        },
      );
      if (response.statusCode == 200 && response.data['error'] == null) {
        return true;
      }
    } catch (e) {
      print('Ошибка Bitrix API: $e');
    }
    return false;
  }

  Future<bool> sendReview({
    required String reviewText,
    required int rating,
  }) async {
    final String url = 'https://$demoDomain/rest/log.blogpost.add.json';
    try {
      final response = await _dio.post(
        url,
        data: {
          'auth': demoToken,
          'POST_TITLE': 'Новый отзыв из приложения',
          'POST_MESSAGE': 'Оценка: $rating/5 \nТекст: $reviewText',
          'DEST': ['UA']
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка Bitrix API: $e');
    }
    return false;
  }
}

class YourMomApp extends StatelessWidget {
  const YourMomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billiard Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xff121212),
        canvasColor: const Color(0xff1e1e1e),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

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
    const ReviewTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Бильярдный Клуб (Bitrix CRM Active)', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff1e1e1e),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.table_bar), label: 'Бронь стола'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Еда и напитки'),
          BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: 'Отзывы'),
        ],
      ),
    );
  }
}

class BookingTab extends StatefulWidget {
  const BookingTab({super.key});

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab> {
  int? selectedTable;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bitrixService = BitrixService();
  bool _isSending = false;

  void _submitBooking() async {
    if (selectedTable == null || _nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля и выберите стол')),
      );
      return;
    }

    setState(() => _isSending = true);

    bool success = await _bitrixService.createBooking(
      clientName: _nameController.text,
      phone: _phoneController.text,
      tableNumber: selectedTable!,
      foodItems: const [],
    );

    setState(() => _isSending = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Бронь успешно отправлена в Битрикс24 CRM!')),
      );
      _nameController.clear();
      _phoneController.clear();
      setState(() => selectedTable = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка отправки запроса в CRM')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Выберите бильярдный стол:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(3, (index) {
              int tableNum = index + 1;
              bool isSelected = selectedTable == tableNum;
              return InkWell(
                onTap: () => setState(() => selectedTable = tableNum),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? Colors.white : Colors.transparent),
                  ),
                  child: Text('Стол №$tableNum', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              );
            }),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Ваше имя',
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            ),
          ),
          TextField(
            controller: _phoneController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Телефон',
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _isSending ? null : _submitBooking,
              child: _isSending 
                ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                : const Text('Подтвердить бронь', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class FoodTab extends StatelessWidget {
  const FoodTab({super.key});

  final List<Map<String, dynamic>> menu = const [
    {'name': 'Бургер Фирменный', 'price': 450, 'icon': '🍔'},
    {'name': 'Картофель фри', 'price': 180, 'icon': '🍟'},
    {'name': 'Кола 0.5', 'price': 120, 'icon': '🥤'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: menu.length,
      itemBuilder: (context, index) {
        final item = menu[index];
        return Card(
          color: const Color(0xff1e1e1e),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Text(item['icon'], style: const TextStyle(fontSize: 30)),
            title: Text(item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('${item['price']} ₽', style: const TextStyle(color: Colors.green)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item['name']} добавлен в корзину заказа')),
                );
              },
              child: const Text('Добавить', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }
}

class ReviewTab extends StatefulWidget {
  const ReviewTab({super.key});

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  final _reviewController = TextEditingController();
  final _bitrixService = BitrixService();
  double _rating = 5.0;
  bool _isSending = false;

  void _submitReview() async {
    if (_reviewController.text.isEmpty) return;

    setState(() => _isSending = true);

    bool success = await _bitrixService.sendReview(
      reviewText: _reviewController.text,
      rating: _rating.round(),
    );

    setState(() => _isSending = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Отзыв опубликован в ленте Битрикс24!')),
 _reviewController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось отправить отзыв')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Оставить отзыв о заведении',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text('Ваша оценка: ', style: TextStyle(color: Colors.white)),
              Slider(
                value: _rating,
                min: 1,
                max: 5,
                divisions: 4,
                label: _rating.round().toString(),
                activeColor: Colors.green,
                onChanged: (value) => setState(() => _rating = value),
              ),
              Text(
                '${_rating.round()} / 5',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reviewController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Напишите ваши впечатления...',
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _isSending ? null : _submitReview,
              child: _isSending
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                    )
                  : const Text('Отправить отзыв', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
