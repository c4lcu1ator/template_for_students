import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Проверка возраста',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AgeCheckScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AgeCheckScreen extends StatefulWidget {
  const AgeCheckScreen({super.key});

  @override
  State<AgeCheckScreen> createState() => _AgeCheckScreenState();
}

class _AgeCheckScreenState extends State<AgeCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  int? _age; // Переменная для хранения возраста
  String? _message;

  void _checkAge() {
    if (_formKey.currentState!.validate()) {
      // Сохраняем возраст в переменную
      _age = int.tryParse(_ageController.text);
      if (_age != null) {
        setState(() {
          _message = _age! >= 18 ? 'Совершеннолетний' : 'Несовершеннолетний';
        });
      }
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Проверка возраста')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Введите возраст',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите возраст';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Введите число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkAge,
                child: const Text('Проверить'),
              ),
              const SizedBox(height: 20),
              if (_message != null)
                Text(
                  _message!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
