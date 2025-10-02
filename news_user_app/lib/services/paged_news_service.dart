import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news.dart';

class PagedNewsService {
  final _db = FirebaseFirestore.instance;
  static const int pageSize = 10;

  Query<Map<String, dynamic>> _baseQuery({String? categoryId}) {
    var q = _db
        .collection('news')
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true);

    if (categoryId != null) {
      q = q.where('categoryId', isEqualTo: categoryId);
    }
    return q;
  }

  DocumentSnapshot? _lastDocAll;
  bool _hasMoreAll = true;

  DocumentSnapshot? _lastDocByCat;
  bool _hasMoreByCat = true;

  Future<List<News>> loadFirstPage({String? categoryId}) async {
    final q = _baseQuery(categoryId: categoryId).limit(pageSize);
    final snap = await q.get();

    final items = snap.docs.map((d) => News.fromMap(d.id, d.data())).toList();

    if (categoryId == null) {
      _lastDocAll = snap.docs.isNotEmpty ? snap.docs.last : null;
      _hasMoreAll = snap.docs.length == pageSize;
    } else {
      _lastDocByCat = snap.docs.isNotEmpty ? snap.docs.last : null;
      _hasMoreByCat = snap.docs.length == pageSize;
    }
    return items;
  }

  Future<List<News>> loadNextPage({String? categoryId}) async {
    if (categoryId == null && !_hasMoreAll) return [];
    if (categoryId != null && !_hasMoreByCat) return [];

    final lastDoc = categoryId == null ? _lastDocAll : _lastDocByCat;

    var q = _baseQuery(categoryId: categoryId).limit(pageSize);
    if (lastDoc != null) q = q.startAfterDocument(lastDoc);

    final snap = await q.get();
    final items = snap.docs.map((d) => News.fromMap(d.id, d.data())).toList();

    if (categoryId == null) {
      _lastDocAll = snap.docs.isNotEmpty ? snap.docs.last : null;
      _hasMoreAll = snap.docs.length == pageSize;
    } else {
      _lastDocByCat = snap.docs.isNotEmpty ? snap.docs.last : null;
      _hasMoreByCat = snap.docs.length == pageSize;
    }
    return items;
  }

  void reset({String? categoryId}) {
    if (categoryId == null) {
      _lastDocAll = null;
      _hasMoreAll = true;
    } else {
      _lastDocByCat = null;
      _hasMoreByCat = true;
    }
  }
}
