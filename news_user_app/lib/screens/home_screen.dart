import 'package:flutter/material.dart';
import '../services/news_service.dart';
import '../models/news.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = NewsService();

    return Scaffold(
      appBar: AppBar(title: const Text("Latest News")),
      body: StreamBuilder<List<News>>(
        stream: service.getPublishedNews(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text("No news published yet."));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final n = items[i];
              return NewsCard(
                news: n,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsDetailScreen(news: n),
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
