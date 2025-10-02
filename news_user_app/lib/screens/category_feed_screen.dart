import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryFeedScreen extends StatelessWidget {
  final String categoryId;   // Firestore la store panna irukkura category id
  final String categoryName; // Display title

  const CategoryFeedScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('news')                    // 🔥 your news collection
            .where('categoryId', isEqualTo: categoryId) // filter by categoryId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No news found in $categoryName"));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final news = docs[i].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(news['title'] ?? ''),
                  subtitle: Text(
                    news['content'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Optional: Navigate to news detail screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
