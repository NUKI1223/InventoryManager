import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dashboard_api.dart';
import '../api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dashboardApiProvider = Provider<DashboardApi>((ref) {
  return DashboardApi(ApiClient(Dio(), const FlutterSecureStorage()));
});

final lowStockProvider = FutureProvider.autoDispose<List>((ref) async {
  final api = ref.watch(dashboardApiProvider);
  return await api.getLowStockProducts(threshold: 10);
});

final zeroStockProvider = FutureProvider.autoDispose<List>((ref) async {
  final api = ref.watch(dashboardApiProvider);
  return await api.getZeroStockProducts();
});

final recentTransactionsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(dashboardApiProvider);
  return await api.getRecentTransactions(limit: 10);
});

final categoryStatsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(dashboardApiProvider);
  return await api.getStatsByCategory();
});
