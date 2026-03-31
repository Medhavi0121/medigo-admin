import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get db => _db;

  CollectionReference collection(String path) => _db.collection(path);

  Future<DocumentReference> add(String collection, Map<String, dynamic> data) {
    return _db.collection(collection).add(data);
  }

  Future<void> set(String collection, String docId, Map<String, dynamic> data) {
    return _db.collection(collection).doc(docId).set(data);
  }

  Future<void> update(
      String collection, String docId, Map<String, dynamic> data) {
    return _db.collection(collection).doc(docId).update(data);
  }

  Future<void> delete(String collection, String docId) {
    return _db.collection(collection).doc(docId).delete();
  }

  Future<DocumentSnapshot> getById(String collection, String docId) {
    return _db.collection(collection).doc(docId).get();
  }

  Stream<QuerySnapshot> streamAll(String collection,
      {String? orderBy, bool descending = false}) {
    var ref = _db.collection(collection);
    if (orderBy != null) {
      return ref
          .orderBy(orderBy, descending: descending)
          .snapshots();
    }
    return ref.snapshots();
  }

  Future<int> count(String collection) async {
    final snap = await _db.collection(collection).count().get();
    return snap.count ?? 0;
  }
}
