import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String categoryId;
  final DateTime? publishedAt;
  final DateTime? createdAt; // ✅ added

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.categoryId,
    this.publishedAt,
    this.createdAt, // ✅ added
  });

  factory News.fromMap(String id, Map<String, dynamic> map) {
    DateTime? _toDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) {
        try { return DateTime.parse(v); } catch (_) {}
      }
      return null;
    }

    return News(
      id: id,
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      categoryId: (map['categoryId'] ?? '').toString(),
      publishedAt: _toDate(map['publishedAt']),
      createdAt: _toDate(map['createdAt']), // ✅ read it if present
    );
  }
}
