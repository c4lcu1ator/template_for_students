import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/student.dart';
import 'home_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final db = DatabaseHelper.instance;
  List<Map<String, dynamic>> grades = [];
  List<Map<String, dynamic>> subjects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final subs = await db.getSubjects();
    final gr = await db.getGradesForStudent(widget.student.id!);
    setState(() {
      subjects = subs;
      grades = gr;
      loading = false;
    });
  }

  Future<void> _addGradeDialog() async {
    if (subjects.isEmpty) return;
    int subjectId = subjects.first['id'] as int;
    double value = 5.0;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Новая оценка (${widget.student.name})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: subjectId,
                items: subjects
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e['id'] as int,
                        child: Text(e['title'] as String),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    subjectId = v;
                  });
                },
              ),
              Slider(
                value: value,
                min: 2.0,
                max: 5.0,
                divisions: 6,
                label: value.toStringAsFixed(1),
                onChanged: (v) {
                  setState(() {
                    value = v;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                await db.insertGrade(
                  studentId: widget.student.id!,
                  subjectId: subjectId,
                  value: value,
                );
                Navigator.of(ctx).pop();
                _loadData();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final avgColor = averageColor(widget.student.average);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: avgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.student.average.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Средний балл',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: grades.isEmpty
                      ? const Center(
                          child: Text('Пока нет оценок. Добавь первую!'),
                        )
                      : ListView.builder(
                          itemCount: grades.length,
                          itemBuilder: (context, index) {
                            final g = grades[index];
                            final value = (g['value'] as num).toDouble();
                            final date = g['date'] as String?;
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(value.toStringAsFixed(1)),
                              ),
                              title: Text(g['title'] as String),
                              subtitle: Text(
                                date != null
                                    ? DateTime.parse(date).toLocal().toString()
                                    : '',
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGradeDialog,
        icon: const Icon(Icons.add),
        label: const Text('Добавить оценку'),
      ),
    );
  }
}
