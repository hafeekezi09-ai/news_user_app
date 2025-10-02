import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_user_app/models/news.dart';
import 'news_detail_screen.dart';

class NewspapersScreen extends StatelessWidget {
  const NewspapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Newspapers")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db
            .collection("categories")
            .where("type", isEqualTo: "newspaper")
            .orderBy("name")
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No newspapers yet."));
          }

          final width = MediaQuery.of(context).size.width;
          // Responsive columns: 2 (phone), 3 (tablet), 5 (desktop)
          final crossAxisCount = width < 520 ? 2 : (width < 900 ? 3 : 5);

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3 / 4, // portrait-ish tile
            ),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data();
              final id = docs[i].id;
              final name = (d['name'] ?? '').toString();
              final cover = (d['coverUrl'] ?? '').toString();

              return _NewspaperCard(
                title: name,
                imageUrl: cover,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        NewspaperDetailScreen(newspaperId: id, newspaperName: name),
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

class _NewspaperCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _NewspaperCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            // Square logo/cover looks nice for newspapers
            AspectRatio(
              aspectRatio: 1, // 1:1
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                      ),
                    )
                  : Container(color: Colors.grey.shade200),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewspaperDetailScreen extends StatelessWidget {
  final String newspaperId;
  final String newspaperName;

  const NewspaperDetailScreen({
    super.key,
    required this.newspaperId,
    required this.newspaperName,
  });

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    final q = db
        .collection("news")
        .where("categoryId", isEqualTo: newspaperId)
        .where("status", isEqualTo: "published")
        .orderBy("publishedAt", descending: true);

    return Scaffold(
      appBar: AppBar(title: Text(newspaperName)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
            return const Center(child: Text("No news for this newspaper."));
          }

          final items = docs.map((d) => News.fromMap(d.id, d.data())).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final n = items[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: n.imageUrl.isNotEmpty
                          ? Image.network(
                              n.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image, color: Colors.grey),
                            )
                          : Container(color: Colors.grey.shade200),
                    ),
                  ),
                  title: Text(n.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    n.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NewsDetailScreen(news: n)),
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
