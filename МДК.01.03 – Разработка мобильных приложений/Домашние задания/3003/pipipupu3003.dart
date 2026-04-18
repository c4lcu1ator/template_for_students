import 'package:flutter/material.dart';

void main() {
  runApp(const StudentsApp());
}

class Student {
  String name;
  double average;
  bool isFavorite;

  Student({
    required this.name,
    required this.average,
    this.isFavorite = false,
  });
}

class StudentsApp extends StatelessWidget {
  const StudentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Students',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StudentsPage(),
    );
  }
}

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final List<Student> _students = [
    Student(name: 'Иван', average: 4.8),
    Student(name: 'Мария', average: 5.0),
    Student(name: 'Алексей', average: 3.2),
  ];

  void _addStudent() {
    final nameController = TextEditingController();
    final gradeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Новый ученик'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                ),
              ),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(
                  labelText: 'Средний балл',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final gradeText = gradeController.text.replaceAll(',', '.');
                final grade = double.tryParse(gradeText);

                if (name.isEmpty || grade == null) {
                  Navigator.of(context).pop();
                  return;
                }

                setState(() {
                  _students.add(
                    Student(name: name, average: grade),
                  );
                });

                Navigator.of(context).pop();
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  void _editGrade(Student student) {
    final gradeController = TextEditingController(
      text: student.average.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Изменить оценку: ${student.name}'),
          content: TextField(
            controller: gradeController,
            decoration: const InputDecoration(
              labelText: 'Средний балл',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final gradeText = gradeController.text.replaceAll(',', '.');
                final grade = double.tryParse(gradeText);
                if (grade == null) {
                  Navigator.of(context).pop();
                  return;
                }

                setState(() {
                  student.average = grade;
                });

                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _toggleFavorite(Student student) {
    setState(() {
      student.isFavorite = !student.isFavorite;
    });
  }

  void _deleteStudent(Student student) {
    setState(() {
      _students.remove(student);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список учеников'),
      ),
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return Dismissible(
            key: ValueKey(student.name + index.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _deleteStudent(student),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: gradeColor(student.average),
                child: Text(
                  student.average.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(student.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      student.isFavorite
                          ? Icons.star
                          : Icons.star_border_outlined,
                      color: student.isFavorite ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorite(student),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editGrade(student),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteStudent(student),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

Color gradeColor(double grade) {
  if (grade >= 5.0) return Colors.green;
  if (grade >= 4.0) return Colors.blue;
  if (grade >= 3.0) return Colors.orange;
  return Colors.red;
}
