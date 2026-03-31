import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/services/firestore_service.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirestoreService _service;
  ProductRepository(this._service);

  Stream<List<ProductModel>> streamAll() {
    return _service
        .streamAll(AppConstants.productsCollection)
        .map((snap) => snap.docs.map((d) => ProductModel.fromFirestore(d)).toList());
  }

  Stream<List<ProductModel>> streamByCategory(String categoryId) {
    return _service
        .collection(AppConstants.productsCollection)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromFirestore(d)).toList());
  }

  Future<List<ProductModel>> getAll() async {
    final snap = await _service
        .collection(AppConstants.productsCollection)
        .get();
    return snap.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  Future<ProductModel?> getById(String id) async {
    final doc = await _service.getById(AppConstants.productsCollection, id);
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  Future<void> add(ProductModel model) async {
    await _service.add(AppConstants.productsCollection, model.toMap());
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _service.update(AppConstants.productsCollection, id, data);
  }

  Future<void> delete(String id) async {
    await _service.delete(AppConstants.productsCollection, id);
  }

  Future<int> count() => _service.count(AppConstants.productsCollection);
}
