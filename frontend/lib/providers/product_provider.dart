import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/product_api.dart';
import '../models/product.dart';
import 'auth_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


final productListProvider = StateNotifierProvider<ProductListNotifier, AsyncValue<List<Product>>>(
      (ref) => ProductListNotifier(ref),
);

class ProductListNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final Ref ref;


  int _currentPage = 0;
  bool _hasMore = true;
  static const int _pageSize = 10;
  int _totalElements = 0;

  ProductListNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchProducts();
  }


  bool get hasMore => _hasMore;
  int get totalElements => _totalElements;
  Future<void> fetchProducts() async {
    try {
      state = const AsyncValue.loading();
      _currentPage = 0;
      _hasMore = true;

      final pageResult = await ref.read(productApiProvider).getProductsPage(
        page: 0,
        size: _pageSize,
      );

      _totalElements = pageResult.totalElements;
      _hasMore = (_currentPage + 1) < pageResult.totalPages;

      state = AsyncValue.data(pageResult.content);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;

    final currentData = state.value ?? [];
    _currentPage++;

    try {
      final pageResult = await ref.read(productApiProvider).getProductsPage(
        page: _currentPage,
        size: _pageSize,
      );

      _totalElements = pageResult.totalElements;
      _hasMore = (_currentPage + 1) < pageResult.totalPages;

      state = AsyncValue.data([...currentData, ...pageResult.content]);
    } catch (e) {
      _currentPage--;
      rethrow;
    }
  }

  void addProduct(Product p) {
    state = state.whenData((list) => [p, ...list]);
    _totalElements++;
  }

  void updateProduct(Product p) {
    state = state.whenData((list) => [
      for (final item in list)
        if (item.id == p.id) p else item,
    ]);
  }

  void removeProduct(int id) {
    state = state.whenData((list) => list.where((p) => p.id != id).toList());
    _totalElements--;
  }

  Product? getById(int id) {
    final list = state.value;
    if (list == null) return null;
    try {
      return list.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

final productProvider = Provider.family<Product?, int>((ref, id) {
  final asyncList = ref.watch(productListProvider);

  return asyncList.when(
    data: (list) {
      try {
        return list.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final productApiProvider = Provider<ProductApi>((ref) {
  return ProductApi(ref.read(apiClientProvider));
});