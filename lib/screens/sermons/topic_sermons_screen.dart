import 'package:flutter/material.dart';
import '../../models/sermon.dart';
import 'sermon_player_screen.dart';

class TopicSermonsScreen extends StatelessWidget {
  final String topic;
  final List<Sermon> sermons;

  const TopicSermonsScreen({
    super.key,
    required this.topic,
    required this.sermons,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: sermons.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_music,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sermons found for this topic',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: sermons.length,
              itemBuilder: (context, index) {
                final sermon = sermons[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      sermon.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(sermon.preacher),
                        const SizedBox(height: 4),
                        Text(
                          sermon.category,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${sermon.duration.inMinutes} min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SermonPlayerScreen(
                            sermon: sermon,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
} 