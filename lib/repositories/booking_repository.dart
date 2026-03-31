import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/services/firestore_service.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final FirestoreService _service;
  BookingRepository(this._service);

  Stream<List<BookingModel>> streamAll() {
    return _service
        .streamAll(AppConstants.bookingsCollection)
        .map((snap) => snap.docs.map((d) => BookingModel.fromFirestore(d)).toList());
  }

  Stream<List<BookingModel>> streamByStatus(String status) {
    return _service
        .collection(AppConstants.bookingsCollection)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snap) => snap.docs.map((d) => BookingModel.fromFirestore(d)).toList());
  }

  Stream<List<BookingModel>> streamByUser(String userId) {
    return _service
        .collection(AppConstants.bookingsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => BookingModel.fromFirestore(d)).toList());
  }

  Future<List<BookingModel>> getAll() async {
    final snap = await _service
        .collection(AppConstants.bookingsCollection)
        .get();
    return snap.docs.map((d) => BookingModel.fromFirestore(d)).toList();
  }

  Future<BookingModel?> getById(String id) async {
    final doc = await _service.getById(AppConstants.bookingsCollection, id);
    if (!doc.exists) return null;
    return BookingModel.fromFirestore(doc);
  }

  Future<void> updateStatus(String id, String status) async {
    await _service.update(AppConstants.bookingsCollection, id, {
      'status': status,
    });
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _service.update(AppConstants.bookingsCollection, id, data);
  }

  Future<void> delete(String id) async {
    await _service.delete(AppConstants.bookingsCollection, id);
  }

  Future<int> count() => _service.count(AppConstants.bookingsCollection);

  Future<int> countByStatus(String status) async {
    final snap = await _service
        .collection(AppConstants.bookingsCollection)
        .where('status', isEqualTo: status)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<double> totalRevenue() async {
    final snap = await _service
        .collection(AppConstants.bookingsCollection)
        .where('status', isEqualTo: 'Completed') // Adjusted to match model default/common case
        .get();
    double total = 0;
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['amount'] ?? 0).toDouble();
    }
    return total;
  }
}
