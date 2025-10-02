import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/news.dart';
import 'news_detail_screen.dart';

class TrendingNewsScreen extends StatelessWidget {
  const TrendingNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('news')
        .where('status', isEqualTo: 'published')
        .where('isTrending', isEqualTo: true) 
        .orderBy('publishedAt', descending: true)
        .limit(20);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text("Error: ${snap.error}"));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No trending news.'));
        }

        final items = docs.map((d) => News.fromMap(d.id, d.data())).toList();
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final n = items[i];
            return ListTile(
              leading: n.imageUrl.isNotEmpty
                  ? Image.network(n.imageUrl, width: 80, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported),
              title: Text(n.title),
              subtitle: Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NewsDetailScreen(news: n)),
              ),
            );
          },
        );
      },
    );
  }
}
