import 'package:flutter/material.dart';
import '../services/supabase_sermon_service.dart';

class SermonCategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const SermonCategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SermonCategories.all.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: category == selectedCategory,
              onSelected: (bool selected) {
                onCategorySelected(selected ? category : null);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
