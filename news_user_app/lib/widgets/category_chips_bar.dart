import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryChipsBar extends StatelessWidget {
  /// Pass in a ValueNotifier to share selected state with the parent.
  final ValueNotifier<String?> selectedCategoryId;

  const CategoryChipsBar({super.key, required this.selectedCategoryId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance
        .collection('categories')
        .orderBy('name');

    return SizedBox(
      height: 48,
      child: StreamBuilder<QuerySnapshot>(
        stream: ref.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final docs = snap.data!.docs;
          // Build: All + Trending + categories
          final chips = <Widget>[];

          // All chip
          chips.add(_Choice(
            label: 'All',
            selected: selectedCategoryId.value == null,
            onSelected: () => selectedCategoryId.value = null,
          ));

          // 🔹 Trending chip
          chips.add(_Choice(
            label: 'Trending',
            selected: selectedCategoryId.value == '_trending',
            onSelected: () => selectedCategoryId.value = '_trending',
          ));

          // Category chips from Firestore
          for (final d in docs) {
            final name = (d['name'] ?? '').toString();
            final id = d.id;
            chips.add(_Choice(
              label: name,
              selected: selectedCategoryId.value == id,
              onSelected: () => selectedCategoryId.value = id,
            ));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => chips[i],
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: chips.length,
          );
        },
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _Choice({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Colors.grey.shade200,
      onSelected: (_) => onSelected(),
    );
  }
}
