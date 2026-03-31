import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/services/firestore_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirestoreService _service;
  CategoryRepository(this._service);

  Stream<List<CategoryModel>> streamAll() {
    return _service
        .streamAll(AppConstants.categoriesCollection)
        .map((snap) => snap.docs.map((d) => CategoryModel.fromFirestore(d)).toList());
  }

  Future<List<CategoryModel>> getAll() async {
    final snap = await _service
        .collection(AppConstants.categoriesCollection)
        .get();
    return snap.docs.map((d) => CategoryModel.fromFirestore(d)).toList();
  }

  Future<void> add(CategoryModel model) async {
    await _service.add(AppConstants.categoriesCollection, model.toMap());
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _service.update(AppConstants.categoriesCollection, id, data);
  }

  Future<void> delete(String id) async {
    await _service.delete(AppConstants.categoriesCollection, id);
  }

  Future<int> count() => _service.count(AppConstants.categoriesCollection);
}
