import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo;
  CategoryProvider(this._repo);

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _filteredCategories;
  List<CategoryModel> get allCategories => _categories;

  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CategoryModel> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    final q = _searchQuery.toLowerCase();
    return _categories
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setCategories(List<CategoryModel> data) {
    _categories = data;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Stream<List<CategoryModel>> streamCategories() {
    _isLoading = true;
    _error = null;
    
    final stream = _repo.streamAll();
    stream.listen(
      (data) {
        _categories = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        debugPrint('CategoryProvider Stream Error: $e');
        notifyListeners();
      },
    );
    return stream;
  }

  Future<void> addCategory(CategoryModel model) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _repo.add(model);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _repo.update(id, data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repo.delete(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
