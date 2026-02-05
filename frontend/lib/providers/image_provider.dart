// lib/providers/image_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/image_api.dart';
import '../models/product.dart';
import 'auth_provider.dart';

final imageApiProvider = Provider((ref) => ImageApi(ref.read(apiClientProvider)));

final uploadNotifierProvider = StateNotifierProvider.family<
    UploadNotifier, AsyncValue<Product?>, int>(
      (ref, productId) => UploadNotifier(ref.read(imageApiProvider), productId),
);

class UploadNotifier extends StateNotifier<AsyncValue<Product?>> {
  final ImageApi api;
  final int productId;

  UploadNotifier(this.api, this.productId) : super(const AsyncValue.loading());

  Future<void> upload(File file) async {
    state = const AsyncValue.loading();
    try {
      final p = await api.uploadImage(productId, file);
      state = AsyncValue.data(p);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
