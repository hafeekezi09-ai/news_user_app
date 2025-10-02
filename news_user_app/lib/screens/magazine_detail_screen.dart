import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/news.dart';
import 'news_detail_screen.dart';

class MagazineDetailScreen extends StatelessWidget {
  final String magazineId;
  final String magazineName;

  const MagazineDetailScreen({
    super.key,
    required this.magazineId,
    required this.magazineName,
  });

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('news')
        .where('categoryId', isEqualTo: magazineId)
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text(magazineName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No articles for this magazine.'));
          }
          final items = docs
              .map((d) => News.fromMap(d.id, d.data() as Map<String, dynamic>))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = items[i];
              return Card(
                child: ListTile(
                  leading: n.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            n.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        )
                      : const Icon(Icons.article),
                  title: Text(n.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    n.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsDetailScreen(news: n),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
