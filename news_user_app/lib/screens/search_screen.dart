import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance
        .collection('news')
        .where('status', isEqualTo: 'published');

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by title…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ref.snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs.where((d) {
                  final title = (d['title'] ?? '').toString().toLowerCase();
                  return _query.isEmpty || title.contains(_query);
                }).toList();

                if (docs.isEmpty) return const Center(child: Text('No results.'));

                final items = docs.map((d) =>
                    News.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final n = items[i];
                    return NewsCard(
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
          ),
        ],
      ),
    );
  }
}
