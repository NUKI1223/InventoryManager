// lib/providers/stock_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/stock_api.dart';
import '../models/product.dart';
import 'auth_provider.dart';

final stockApiProvider = Provider((ref) => StockApi(ref.read(apiClientProvider)));

final adjustNotifierProvider = StateNotifierProvider.family<
    AdjustNotifier, AsyncValue<Product?>, int>(
      (ref, productId) => AdjustNotifier(ref.read(stockApiProvider), productId),
);

class AdjustNotifier extends StateNotifier<AsyncValue<Product?>> {
  final StockApi api;
  final int productId;

  AdjustNotifier(this.api, this.productId) : super(const AsyncValue.loading());

  Future<void> adjust(int change, String type) async {
    state = const AsyncValue.loading();
    try {
      final p = await api.adjustStock(productId, change, type);
      state = AsyncValue.data(p); // p — non-null Product
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
