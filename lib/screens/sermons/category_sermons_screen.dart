import 'package:flutter/material.dart';
import '../../models/sermon.dart';
import 'sermon_player_screen.dart';

class CategorySermonsScreen extends StatelessWidget {
  final String category;
  final List<Sermon> sermons;

  const CategorySermonsScreen({
    super.key,
    required this.category,
    required this.sermons,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: sermons.length,
        itemBuilder: (context, index) {
          final sermon = sermons[index];
          return ListTile(
            title: Text(sermon.title),
            subtitle: Text(sermon.preacher),
            trailing: Text(
              '${sermon.duration.inMinutes} min',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SermonPlayerScreen(sermon: sermon),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
