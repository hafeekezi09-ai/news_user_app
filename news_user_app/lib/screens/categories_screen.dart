import 'package:flutter/material.dart';
import 'package:news_user_app/models/categories.dart';
import 'package:news_user_app/services/category_service.dart';
import 'category_feed_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catService = CategoryService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
      ),
      body: StreamBuilder<List<Category>>(
        stream: catService.streamAll(), // get all categories as a stream
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          final cats = snap.data ?? [];
          if (cats.isEmpty) {
            return const Center(child: Text("No categories yet."));
          }

          return ListView.separated(
            itemCount: cats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = cats[i];
              return ListTile(
                leading: (c.coverUrl != null && c.coverUrl!.isNotEmpty)
                    ? CircleAvatar(backgroundImage: NetworkImage(c.coverUrl!))
                    : const CircleAvatar(child: Icon(Icons.category)),
                title: Text(
                  c.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  [
                    c.type,
                    if (c.content != null && c.content!.isNotEmpty) c.content!,
                  ].join(' • '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  // Navigate to feed filtered by this category
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryFeedScreen(
                        categoryId: c.id ?? '',
                        categoryName: c.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
