import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repo;
  BookingProvider(this._repo);

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _filteredBookings;

  String _searchQuery = '';
  String _statusFilter = 'all';
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _bookings.length;

  int countByStatus(String status) =>
      _bookings.where((b) => b.status.toLowerCase() == status.toLowerCase()).length;

  double get totalRevenue => _bookings
      .where((b) => b.status.toLowerCase() == 'completed')
      .fold(0.0, (sum, b) => sum + b.amount);

  List<BookingModel> get _filteredBookings {
    var list = _bookings;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((b) =>
          b.patientName.toLowerCase().contains(q) ||
          b.title.toLowerCase().contains(q) ||
          b.id.toLowerCase().contains(q)).toList();
    }
    if (_statusFilter != 'all') {
      list = list.where((b) => b.status.toLowerCase() == _statusFilter.toLowerCase()).toList();
    }
    return list;
  }

  void setSearch(String q) { _searchQuery = q; notifyListeners(); }
  void setStatusFilter(String f) { _statusFilter = f; notifyListeners(); }

  void setBookings(List<BookingModel> data) {
    _bookings = data;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Stream<List<BookingModel>> streamBookings() {
    _isLoading = true;
    _error = null;

    final stream = _repo.streamAll();
    stream.listen(
      (data) {
        _bookings = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        debugPrint('BookingProvider Stream Error: $e');
        notifyListeners();
      },
    );
    return stream;
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _repo.updateStatus(id, status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBooking(String id) async {
    try {
      await _repo.delete(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
