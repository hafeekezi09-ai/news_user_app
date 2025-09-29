import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/news.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;
  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final DateTime? displayDate = news.publishedAt ?? news.createdAt; // ✅ fallback

    return Scaffold(
      appBar: AppBar(title: Text(news.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(news.imageUrl),
              ),
            const SizedBox(height: 16),
            Text(
              news.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (displayDate != null) ...[
              const SizedBox(height: 8),
              Text(
                "Published: ${DateFormat.yMMMd().add_jm().format(displayDate)}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 16),
            Text(news.content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
