import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_user_app/models/categories.dart';


class CategoryService {
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('categories');

  
  Stream<List<Category>> streamAll() {
    return _col
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => Category.fromMap(d.id, d.data())).toList());
  }

  
  Future<List<Category>> getAllOnce() async {
    final s = await _col.orderBy('name').get();
    return s.docs.map((d) => Category.fromMap(d.id, d.data())).toList();
  }

  
  Future<List<Category>> getCategories() => getAllOnce();
}
