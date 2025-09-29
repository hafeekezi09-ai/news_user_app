import 'package:flutter/material.dart';
import 'package:news_user_app/models/categories.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback onSelected;

  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        category.name,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: selected,
      selectedColor: Colors.green,
      backgroundColor: Colors.grey.shade200,
      onSelected: (_) => onSelected(),
    );
  }
}
