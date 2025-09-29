import 'package:flutter/material.dart';
import '../models/news.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final VoidCallback? onTap; // ✅ external tap handler

  const NewsCard({
    super.key,
    required this.news,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: news.imageUrl.isNotEmpty
            ? Image.network(
                news.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.article, size: 40),
        title: Text(
          news.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          news.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap, // ✅ use the passed handler
      ),
    );
  }
}
