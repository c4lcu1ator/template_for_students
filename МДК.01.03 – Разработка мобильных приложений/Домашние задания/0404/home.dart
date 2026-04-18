import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/student.dart';
import 'student_detail_screen.dart';
import 'reactor_screen.dart';

Color averageColor(double value) {
  if (value >= 5.0) return Colors.green;
  if (value >= 4.0) return Colors.blue;
  if (value >= 3.0) return Colors.orange;
  return Colors.red;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseHelper.instance;
  List<Student> students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => loading = true);
    final data = await db.getAllStudents();
    setState(() {
      students = data;
      loading = false;
    });
  }

  Future<void> _addStudentDialog() async {
    final nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Новый ученик'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Имя',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  Navigator.of(ctx).pop();
                  return;
                }
                await db.insertStudent(
                  Student(name: name),
                );
                Navigator.of(ctx).pop();
                _loadStudents();
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStudent(Student student) async {
    if (student.id == null) return;
    await db.deleteStudent(student.id!);
    _loadStudents();
  }

  Future<void> _toggleFavorite(Student student) async {
    if (student.id == null) return;
    final updated = student.copyWith(isFavorite: !student.isFavorite);
    await db.updateStudent(updated);
    _loadStudents();
  }

  void _openDetails(Student student) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudentDetailScreen(student: student),
      ),
    ).then((_) => _loadStudents());
  }

  void _openReactor() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ReactorScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список учеников'),
        actions: [
          IconButton(
            icon: const Icon(Icons.science_outlined),
            onPressed: _openReactor,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(child: Text('Нет учеников. Добавь первого!'))
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final s = students[index];
                    return Dismissible(
                      key: ValueKey(s.id ?? s.name),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteStudent(s),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: averageColor(s.average),
                          child: Text(
                            s.average.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(s.name),
                        subtitle: s.isFavorite
                            ? const Text('Избранный ученик')
                            : null,
                        trailing: IconButton(
                          icon: Icon(
                            s.isFavorite ? Icons.star : Icons.star_border,
                            color:
                                s.isFavorite ? Colors.amber : Colors.grey[400],
                          ),
                          onPressed: () => _toggleFavorite(s),
                        ),
                        onTap: () => _openDetails(s),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
