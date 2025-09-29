import 'package:flutter/material.dart';
import 'package:news_user_app/models/categories.dart';
import '../services/category_service.dart';
import '../services/news_service.dart';
  // ✅ FIXED import
import '../models/news.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catService = CategoryService();

    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: StreamBuilder<List<Category>>(
        stream: catService.getCategories(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final cats = snap.data!;
          if (cats.isEmpty) return const Center(child: Text("No categories yet."));
          return ListView.separated(
            itemCount: cats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = cats[i];
              return ListTile(
                title: Text(c.name),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => _CategoryNewsList(category: c)),
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

class _CategoryNewsList extends StatelessWidget {
  final Category category;
  const _CategoryNewsList({required this.category});

  @override
  Widget build(BuildContext context) {
    final newsService = NewsService();
    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: StreamBuilder<List<News>>(
        stream: newsService.getNewsByCategory(category.id),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text("No news in this category."));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final n = items[i];
              return NewsCard(
                news: n,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NewsDetailScreen(news: n)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
