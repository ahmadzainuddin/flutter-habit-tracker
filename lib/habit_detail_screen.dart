import 'package:flutter/material.dart';

class HabitDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const HabitDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = item['title'] ?? 'Habit';
    final String description = item['description'] ?? '';
    final Color? color = item['color'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (color != null)
                  CircleAvatar(backgroundColor: color, radius: 14),
                if (color != null) const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (description.isNotEmpty) Text(description),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to List'),
            ),
          ],
        ),
      ),
    );
  }
}

