import 'package:flutter/material.dart';
import '../models/news.dart';
import '../utils/formatters.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final VoidCallback onTap;

  const NewsCard({super.key, required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final when = timeAgo(news.publishedAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: news.imageUrl.isNotEmpty
              ? Image.network(news.imageUrl, width: 80, fit: BoxFit.cover)
              : const Icon(Icons.article, size: 40, color: Colors.grey),
        ),
        title: Text(news.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (when.isNotEmpty)
              Text(when, style: Theme.of(context).textTheme.bodySmall),
            Text(
              news.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
