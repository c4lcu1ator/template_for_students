import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лайк с счётчиком'),
      ),
      body: const Center(
        child: LikeButtonWithCounter(),
      ),
    );
  }
}

class LikeButtonWithCounter extends StatefulWidget {
  const LikeButtonWithCounter({super.key});

  @override
  State<LikeButtonWithCounter> createState() => _LikeButtonWithCounterState();
}

class _LikeButtonWithCounterState extends State<LikeButtonWithCounter> {
  bool _isLiked = false;
  int _count = 0;

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        // Был лайк — снимаем
        _isLiked = false;
        _count = 0;
      } else {
        // Не было лайка — ставим
        _isLiked = true;
        _count = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
          ),
          color: _isLiked ? Colors.red : Colors.grey,
          iconSize: 32,
          onPressed: _toggleLike,
        ),
        const SizedBox(width: 8),
        Text(
          '$_count',
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
