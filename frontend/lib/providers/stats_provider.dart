import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/audit_api.dart';
import '../models/stats.dart';

final statsProvider = FutureProvider<Stats>((ref) async {
  final api = ref.read(auditApiProvider);
  return api.getStats();
});

final statsProviderWithProducts = FutureProvider.family<Stats, List<int>>((ref, productIds) async {
  final api = ref.read(auditApiProvider);
  return api.getStatsByProducts(productIds);
});