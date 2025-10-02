import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_user_app/models/categories.dart';


class CategoryService {
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('categories');

  /// ✅ Use this with StreamBuilder (live updates)
  Stream<List<Category>> streamAll() {
    return _col
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => Category.fromMap(d.id, d.data())).toList());
  }

  /// Optional: one-time fetch (use with FutureBuilder)
  Future<List<Category>> getAllOnce() async {
    final s = await _col.orderBy('name').get();
    return s.docs.map((d) => Category.fromMap(d.id, d.data())).toList();
  }

  /// Backward-compat name some codebases use
  Future<List<Category>> getCategories() => getAllOnce();
}
