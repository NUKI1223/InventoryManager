import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/category_api.dart';
import '../api/api_client_provider.dart';
import '../models/category.dart';

final categoryApiProvider = Provider<CategoryApi>((ref) {
  return CategoryApi(ref.read(apiClientProvider));
});

final categoryListProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.read(categoryApiProvider);
  return api.getAll();
});
