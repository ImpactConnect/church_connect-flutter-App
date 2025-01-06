import 'package:flutter/material.dart';
import 'category_sermons_screen.dart';

class CategoryListScreen extends StatelessWidget {
  final List<String> categories;

  const CategoryListScreen({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            leading: const Icon(Icons.category),
            title: Text(category),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategorySermonsScreen(
                    category: category,
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
