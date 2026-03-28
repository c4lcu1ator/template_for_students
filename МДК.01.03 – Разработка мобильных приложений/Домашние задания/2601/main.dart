import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Цвет фона Scaffold
      backgroundColor: Colors.lightBlueAccent,

      appBar: AppBar(
        title: const Text('Домашняя работа'),
        backgroundColor: Colors.blue,
      ),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            // Изменённая иконка + цвет + размер
            Icon(
              Icons.school,        // другая иконка из Icons.
              color: Colors.white, // цвет иконки
              size: 80,            // размер иконки
            ),
            SizedBox(height: 20),
            // Текст с ФИО
            Text(
              'Курганский Максим Васильевич',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
