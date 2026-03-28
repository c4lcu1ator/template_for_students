import 'package:flutter/material.dart';

class SimpleMusicPlayer extends StatefulWidget {
  const SimpleMusicPlayer({super.key});

  @override
  State<SimpleMusicPlayer> createState() => _SimpleMusicPlayerState();
}

class _SimpleMusicPlayerState extends State<SimpleMusicPlayer> {
  bool _isPlaying = false;

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    // здесь должна быть логика проигрывания/паузы
    // например через just_audio / audioplayers
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Обложка трека БЕЗ иконки play поверх
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://picsum.photos/300/300',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),

          // Название трека / артист
          const Text(
            'Название трека',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Имя исполнителя',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Ряд иконок, play/pause по ЦЕНТРУ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                color: Colors.white,
                iconSize: 28,
                onPressed: () {
                  // предыдущий трек
                },
              ),
              const SizedBox(width: 16),

              // Play/Pause по центру
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                ),
                color: Colors.white,
                iconSize: 40,
                onPressed: _togglePlay,
              ),

              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next),
                color: Colors.white,
                iconSize: 28,
                onPressed: () {
                  // следующий трек
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
