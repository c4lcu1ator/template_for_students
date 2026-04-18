import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/student.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static const String _dbName = 'students_app.db';
  static const int _dbVersion = 1;

  static const String tableStudents = 'students';
  static const String tableSubjects = 'subjects';
  static const String tableGrades = 'grades';
  static const String tableSettings = 'settings';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableStudents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        average REAL NOT NULL DEFAULT 0.0
      );
    ''');

    await db.execute('''
      CREATE TABLE $tableSubjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE $tableGrades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        subject_id INTEGER NOT NULL,
        value REAL NOT NULL,
        date TEXT,
        FOREIGN KEY(student_id) REFERENCES $tableStudents(id),
        FOREIGN KEY(subject_id) REFERENCES $tableSubjects(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE $tableSettings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT
      );
    ''');

    await db.insert(tableSubjects, {'title': 'Математика'});
    await db.insert(tableSubjects, {'title': 'Физика'});
    await db.insert(tableSubjects, {'title': 'Информатика'});
  }

  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert(tableStudents, student.toMap());
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final maps = await db.query(
      tableStudents,
      orderBy: 'name ASC',
    );
    return maps.map((e) => Student.fromMap(e)).toList();
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      tableStudents,
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete(
      tableStudents,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    final db = await database;
    return db.query(tableSubjects, orderBy: 'title ASC');
  }

  Future<int> insertGrade({
    required int studentId,
    required int subjectId,
    required double value,
  }) async {
    final db = await database;
    final id = await db.insert(tableGrades, {
      'student_id': studentId,
      'subject_id': subjectId,
      'value': value,
      'date': DateTime.now().toIso8601String(),
    });
    await _recalculateAverage(studentId);
    return id;
  }

  Future<List<Map<String, dynamic>>> getGradesForStudent(int studentId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT g.id, g.value, g.date, s.title
      FROM $tableGrades g
      JOIN $tableSubjects s ON g.subject_id = s.id
      WHERE g.student_id = ?
      ORDER BY g.date DESC;
    ''', [studentId]);
  }

  Future<void> _recalculateAverage(int studentId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(value) as avg_value FROM $tableGrades WHERE student_id = ?',
      [studentId],
    );
    final avg = (result.first['avg_value'] ?? 0.0) as num;
    await db.update(
      tableStudents,
      {'average': avg.toDouble()},
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      tableSettings,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final res = await db.query(
      tableSettings,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return res.first['value'] as String?;
  }
}
