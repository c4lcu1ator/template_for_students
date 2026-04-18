import 'dart:convert';

class Student {
  final int? id;
  final String name;
  final bool isFavorite;
  final double average;

  Student({
    this.id,
    required this.name,
    this.isFavorite = false,
    this.average = 0.0,
  });

  Student copyWith({
    int? id,
    String? name,
    bool? isFavorite,
    double? average,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      isFavorite: isFavorite ?? this.isFavorite,
      average: average ?? this.average,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_favorite': isFavorite ? 1 : 0,
      'average': average,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      isFavorite: (map['is_favorite'] ?? 0) == 1,
      average: (map['average'] ?? 0.0) * 1.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Student.fromJson(String source) =>
      Student.fromMap(json.decode(source) as Map<String, dynamic>);
}
