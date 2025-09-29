import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news.dart';

class NewsService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _news =>
      _db.collection('news');

  Stream<List<News>> getPublishedNews() {
    return _news
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((snap) {
      final items = snap.docs
          .map((d) => News.fromMap(d.id, d.data()))
          .toList();

      items.sort((a, b) {
        final aTime = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime); // newest first
      });
      return items;
    });
  }

  Stream<List<News>> getNewsByCategory(String categoryId) {
    return _news
        .where('status', isEqualTo: 'published')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snap) {
      final items = snap.docs
          .map((d) => News.fromMap(d.id, d.data()))
          .toList();

      items.sort((a, b) {
        final aTime = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return items;
    });
  }
}
