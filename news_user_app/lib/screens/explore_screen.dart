
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/news.dart';
import '../utils/formatters.dart'; 
import 'news_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, inner) => [
              SliverAppBar(
                pinned: true,
                floating: true,
                forceElevated: inner,
                title: const Text(
                  'Daily News',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
actions: [   
    IconButton(
      icon: const Icon(Icons.notifications_none),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notifications clicked")),
        );
      },
    ),
    IconButton(
      icon: const Icon(Icons.language),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Select Language"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("English"),
                  onTap: () => Navigator.pop(context, "en"),
                ),
                ListTile(
                  title: const Text("தமிழ் (Tamil)"),
                  onTap: () => Navigator.pop(context, "ta"),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ], 


                bottom: const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Top News'),
                    Tab(text: 'Trending'),
                  ],
                ),
              ),
            ],
            body: const TabBarView(
              children: [
                _TopNewsList(),
                _TrendingList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ----------------- helpers ----------------- */

double _bottomInset(BuildContext context) =>
    MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;

News _toNews(DocumentSnapshot d) =>
    News.fromMap(d.id, d.data() as Map<String, dynamic>);

Widget _error(Object e) => Center(child: Text('Error: $e'));
Widget _loading() => const Center(child: CircularProgressIndicator());

/* ===================== TOP NEWS ===================== */

class _TopNewsList extends StatelessWidget {
  const _TopNewsList();

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('news')
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .limit(50);

    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loading();
        if (snap.hasError) return _error(snap.error!);

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No news yet.'));

        final items = docs.map(_toNews).toList();

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(16, 12, 16, _bottomInset(context)),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _NewsTile(items[i]),
        );
      },
    );
  }
}

/* ===================== TRENDING ===================== */

class _TrendingList extends StatelessWidget {
  const _TrendingList();

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('news')
        .where('status', isEqualTo: 'published')
        .where('isTrending', isEqualTo: true) //  use trending flag
        .orderBy('publishedAt', descending: true)
        .limit(50);

    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loading();
        if (snap.hasError) return _error(snap.error!);

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No trending stories yet.'));
        }

        final items = docs.map(_toNews).toList();

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(16, 12, 16, _bottomInset(context)),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _NewsTile(items[i]),
        );
      },
    );
  }
}

/* ===================== shared tile ===================== */

class _NewsTile extends StatelessWidget {
  final News n;
  const _NewsTile(this.n);

  @override
  Widget build(BuildContext context) {
    final when = n.publishedAt != null ? timeAgo(n.publishedAt!) : '';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 76,
            height: 76,
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (when.isNotEmpty)
              Text(when, style: Theme.of(context).textTheme.bodySmall),
            Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewsDetailScreen(news: n)),
        ),
      ),
    );
  }
}
