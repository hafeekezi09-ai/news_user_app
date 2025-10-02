import 'package:flutter/material.dart';
import '../models/news.dart';
import '../utils/formatters.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;
  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final when = timeAgo(news.publishedAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(news.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // hook share_plus if you want
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shared!')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          if (news.imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  news.imageUrl,
                  height: 200,          // ✅ small fixed height
                  width: double.infinity,
                  fit: BoxFit.contain,  // ✅ show full image (not cropped)
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image,
                        color: Colors.grey, size: 28),
                  ),
                ),
              ),
            ),
          Container(
            color: const Color(0xFFEAF5E7), // soft green like your theme
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                if (when.isNotEmpty)
                  Text(when, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text(
                  news.content,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
