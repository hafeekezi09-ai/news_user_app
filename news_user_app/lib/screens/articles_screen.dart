import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/news.dart';
import 'news_detail_screen.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('news')
        .where('status', isEqualTo: 'published')
        .where('type', isEqualTo: 'article')
        .orderBy('publishedAt', descending: true)
        .limit(50);

    // responsive columns
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 520
        ? 1
        : (width < 760 ? 2 : (width < 1100 ? 3 : 4));

    // tune card aspect per breakpoint (taller cards reduce overflow risk)
    final childAspectRatio = width < 520
        ? 0.95
        : (width < 760 ? 0.8 : (width < 1100 ? 0.78 : 0.76));

    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: ${snap.error}', textAlign: TextAlign.center),
              ),
            );
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No articles yet.'));
          }

          final items = docs
              .map((d) => News.fromMap(d.id, d.data()))
              .toList(growable: false);

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final n = items[i];
              return _ArticleCard(
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

class _ArticleCard extends StatelessWidget {
  final News news;
  final VoidCallback onTap;
  const _ArticleCard({required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = news.imageUrl.trim().isNotEmpty;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area expands to fill remaining vertical space cleanly.
            Expanded(
              child: hasImage
                  ? Image.network(
                      news.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 32),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, size: 32),
                    ),
            ),

            // Fixed-height footer avoids overflow.
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              // height tuned for 2 lines title + 1 line snippet
              constraints: const BoxConstraints(minHeight: 72, maxHeight: 84),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
