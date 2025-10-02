import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news.dart';

class NewsService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _news => _db.collection('news');

  // ---------- helpers ----------
  List<News> _sortByPublishedAtDesc(Iterable<News> items) {
    final list = items.toList();
    list.sort((a, b) {
      final aT = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bT = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bT.compareTo(aT);
    });
    return list;
  }

  // ---------- streams ----------

  Stream<List<News>> streamPublished({int limit = 50}) {
    return _news
        .where('status', isEqualTo: 'published')
        .limit(limit)
        .snapshots()
        .map(
          (s) => _sortByPublishedAtDesc(
            s.docs.map((d) => News.fromMap(d.id, d.data())),
          ),
        );
  }

  Stream<List<News>> streamByCategory(String categoryId, {int limit = 50}) {
    return _news
        .where('status', isEqualTo: 'published')
        .where('categoryId', isEqualTo: categoryId)
        .limit(limit)
        .snapshots()
        .map(
          (s) => _sortByPublishedAtDesc(
            s.docs.map((d) => News.fromMap(d.id, d.data())),
          ),
        );
  }

  Stream<List<News>> streamTrending({bool byViews = false, int limit = 50}) {
    return _news
        .where('status', isEqualTo: 'published')
        .where('isTrending', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map((s) {
          var items = s.docs.map((d) => News.fromMap(d.id, d.data())).toList();
          if (byViews) {
            items.sort((a, b) {
              final v = b.views.compareTo(a.views);
              if (v != 0) return v;
              final aT =
                  a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bT =
                  b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bT.compareTo(aT);
            });
            return items;
          }
          return _sortByPublishedAtDesc(items);
        });
  }

  // ---------- utilities ----------
  Future<void> incrementViews(String id) async {
    await _news.doc(id).update({'views': FieldValue.increment(1)});
  }

  Future<News?> getById(String id) async {
    final d = await _news.doc(id).get();
    if (!d.exists) return null;
    return News.fromMap(d.id, d.data()!);
  }

  Stream<List<News>> getPublishedNews() => streamPublished();
  Stream<List<News>> getNewsByCategory(String categoryId) =>
      streamByCategory(categoryId);
}
