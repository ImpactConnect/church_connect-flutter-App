import 'package:flutter/material.dart';
import 'preacher_sermons_screen.dart';

class PreacherListScreen extends StatelessWidget {
  final List<String> preachers;

  const PreacherListScreen({
    super.key,
    required this.preachers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preachers'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: preachers.length,
        itemBuilder: (context, index) {
          final preacher = preachers[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(preacher[0]),
            ),
            title: Text(preacher),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PreacherSermonsScreen(
                    preacher: preacher,
                    sermons: const [], // We'll load sermons in the next screen
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
