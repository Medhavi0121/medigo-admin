import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repo;
  UserProvider(this._repo);

  List<UserModel> _users = [];
  List<UserModel> get users => _filteredUsers;

  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _users.length;

  List<UserModel> get _filteredUsers {
    var list = _users;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((u) =>
          u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.phone.contains(q)).toList();
    }
    return list;
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  Stream<List<UserModel>> streamUsers() {
    _isLoading = true;
    _error = null;

    final stream = _repo.streamAll();
    stream.listen(
      (data) {
        _users = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        debugPrint('UserProvider Stream Error: $e');
        notifyListeners();
      },
    );
    return stream;
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repo.update(id, data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _repo.delete(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
