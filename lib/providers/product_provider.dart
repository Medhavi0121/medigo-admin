import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repo;
  ProductProvider(this._repo);

  List<ProductModel> _products = [];
  List<ProductModel> get products => _filteredProducts;

  String _searchQuery = '';
  String _categoryFilter = 'all';
  String _statusFilter = 'all';
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _products.length;
  int get activeCount => _products.where((p) => p.status).length;
  String get categoryFilter => _categoryFilter;
  String get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  List<ProductModel> get _filteredProducts {
    var list = _products;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q)).toList();
    }
    if (_categoryFilter != 'all') {
      list = list.where((p) => p.categoryId == _categoryFilter).toList();
    }
    if (_statusFilter == 'active') {
      list = list.where((p) => p.status).toList();
    } else if (_statusFilter == 'inactive') {
      list = list.where((p) => !p.status).toList();
    }
    return list;
  }

  void setSearch(String q) { _searchQuery = q; notifyListeners(); }
  void setCategoryFilter(String f) { _categoryFilter = f; notifyListeners(); }
  void setStatusFilter(String f) { _statusFilter = f; notifyListeners(); }

  void setProducts(List<ProductModel> data) {
    _products = data;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Stream<List<ProductModel>> streamProducts() {
    _isLoading = true;
    _error = null;
    
    final stream = _repo.streamAll();
    stream.listen(
      (data) {
        _products = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        debugPrint('ProductProvider Stream Error: $e');
        notifyListeners();
      },
    );
    return stream;
  }

  Future<void> addProduct(ProductModel model) async {
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

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
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

  Future<void> deleteProduct(String id) async {
    try {
      await _repo.delete(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
