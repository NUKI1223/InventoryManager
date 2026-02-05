import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/product_api.dart';
import '../models/product.dart';
import '../models/page_result.dart';
import 'product_provider.dart';

final searchNotifierProvider = StateNotifierProvider<SearchNotifier, AsyncValue<PageResult<Product>>>(
      (ref) => SearchNotifier(ref.read(productApiProvider)),
);

class SearchNotifier extends StateNotifier<AsyncValue<PageResult<Product>>> {
  final ProductApi api;
  String _lastQ = '';
  String _lastSort = '';
  int? _lastCategoryId;
  int _lastPage = 0;
  final int pageSize = 20;

  SearchNotifier(this.api) : super(const AsyncValue.loading());

  Future<void> search({String? q, String? sort, int? categoryId, int page = 0}) async {
    _lastQ = q ?? '';
    _lastSort = sort ?? '';
    _lastCategoryId = categoryId;
    _lastPage = page;
    state = const AsyncValue.loading();
    try {
      final res = await api.getProductsPage(
        q: _lastQ.isEmpty ? null : _lastQ,
        sort: _lastSort.isEmpty ? null : _lastSort,
        categoryId: _lastCategoryId,
        page: _lastPage,
        size: pageSize,
      );
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> nextPage() async {
    final current = state.value;
    if (current == null) return;
    if (current.number + 1 >= current.totalPages) return;

    final nextPageNum = current.number + 1;
    state = const AsyncValue.loading();
    try {
      final res = await api.getProductsPage(
        q: _lastQ.isEmpty ? null : _lastQ,
        sort: _lastSort.isEmpty ? null : _lastSort,
        categoryId: _lastCategoryId,
        page: nextPageNum,
        size: pageSize,
      );

      final combined = PageResult<Product>(
        content: [...current.content, ...res.content],
        number: res.number,
        size: res.size,
        totalPages: res.totalPages,
        totalElements: res.totalElements,
      );
      state = AsyncValue.data(combined);
      _lastPage = nextPageNum;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await search(q: _lastQ, sort: _lastSort, categoryId: _lastCategoryId, page: 0);
  }
}
