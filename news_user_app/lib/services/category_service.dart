import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_user_app/models/categories.dart';


class CategoryService {
  final _ref = FirebaseFirestore.instance.collection('categories');

  Stream<List<Category>> getCategories() {
    return _ref.snapshots().map((s) =>
        s.docs.map((d) => Category.fromMap(d.id, d.data())).toList());
  }
}
