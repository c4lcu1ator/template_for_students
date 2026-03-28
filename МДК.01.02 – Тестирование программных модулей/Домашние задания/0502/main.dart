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
      home: PlaylistScreen(),
    );
  }
}

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final List<String> _tracks = [
    'Track 1',
    'Track 2',
    'Track 3',
  ];

  // Диалог подтверждения удаления
  Future<void> _showDeleteDialog(int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить трек'),
          content: Text('Вы точно хотите удалить "${_tracks[index]}" из плейлиста?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Удалить',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _tracks.removeAt(index);
      });
    }
  }

  // Диалог добавления трека
  Future<void> _showAddTrackDialog() async {
    final TextEditingController controller = TextEditingController();

    final String? newTrack = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить трек'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Название трека',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  Navigator.of(context).pop(null);
                } else {
                  Navigator.of(context).pop(controller.text.trim());
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );

    if (newTrack != null) {
      setState(() {
        _tracks.add(newTrack);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой плейлист'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Добавить трек',
            onPressed: _showAddTrackDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tracks.length,
        itemBuilder: (context, index) {
          final track = _tracks[index];
          return ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(track),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(index),
            ),
            onTap: () {
              // тут можно открыть экран с плеером или показать другой диалог
            },
          );
        },
      ),
    );
  }
}
