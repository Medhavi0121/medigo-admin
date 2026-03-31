import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/services/firestore_service.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirestoreService _service;
  UserRepository(this._service);

  Stream<List<UserModel>> streamAll() {
    return _service
        .streamAll(AppConstants.usersCollection)
        .map((snap) => snap.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Future<List<UserModel>> getAll() async {
    final snap = await _service.collection(AppConstants.usersCollection).get();
    return snap.docs.map((d) => UserModel.fromFirestore(d)).toList();
  }

  Future<UserModel?> getById(String id) async {
    final doc = await _service.getById(AppConstants.usersCollection, id);
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _service.update(AppConstants.usersCollection, id, data);
  }

  Future<void> delete(String id) async {
    await _service.delete(AppConstants.usersCollection, id);
  }

  Future<int> count() => _service.count(AppConstants.usersCollection);
}
