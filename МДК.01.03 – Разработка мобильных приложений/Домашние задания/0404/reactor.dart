import 'dart:math';
import 'package:flutter/material.dart';

class ReactorScreen extends StatefulWidget {
  const ReactorScreen({super.key});

  @override
  State<ReactorScreen> createState() => _ReactorScreenState();
}

class _ReactorScreenState extends State<ReactorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double power = 0.3;
  bool selfDestruct = false;
  final random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSelfDestruct() {
    setState(() {
      selfDestruct = !selfDestruct;
    });
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Кнопка самоуничтожения'),
          content: const Text(
            'Самоуничтожение запущено!\n\n'
            'Шутка :) Это учебное приложение, никаких реакторов тут нет.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Фух'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(
      Colors.green,
      Colors.red,
      power.clamp(0.0, 1.0),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Реактор Перри Утконоса'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Мощность реактора: ${(power * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1.0 + _controller.value * 0.2 * power;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color!.withOpacity(0.6),
                        blurRadius: 40 * power,
                        spreadRadius: 10 * power,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'CORE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Slider(
            value: power,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: (power * 100).toStringAsFixed(0),
            onChanged: (v) {
              setState(() {
                power = v;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _toggleSelfDestruct,
            icon: const Icon(Icons.warning_amber_rounded),
            label: const Text('Кнопка самоуничтожения'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Искуственный интеллект Перри Утконоса наблюдает за тобой.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
