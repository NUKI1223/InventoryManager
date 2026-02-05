import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import '../models/change_record.dart';
import '../models/page_result.dart';
import '../models/stats.dart';
import 'api_client_provider.dart';

class AuditApi {
  final ApiClient api;
  AuditApi(this.api);

  Future<Stats> getStatsByProducts(List<int> productIds) async {
    final res = await api.dio.get('/api/stats', queryParameters: {
      'productIds': productIds.join(','),
    });
    return Stats.fromJson(res.data);
  }

  Future<PageResult<ChangeRecord>> getHistory({
    int page = 0,
    int size = 20,
    int? productId,
    String? action,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'size': size};
      if (productId != null) params['productId'] = productId;
      if (action != null) params['action'] = action;

      final resp = await api.dio.get('/api/history', queryParameters: params);
      final data = resp.data as Map<String, dynamic>;
      return PageResult.fromJson(data, (m) => ChangeRecord.fromJson(m));
    } on DioError catch (e) {
      // Логируем тело ошибки сервера для отладки
      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception('History request failed (status: $status). body: $body');
    }
  }

  Future<Stats> getStats() async {
    try {
      final resp = await api.dio.get('/api/stats');
      final data = resp.data as Map<String, dynamic>;
      return Stats.fromJson(data);
    } on DioError catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception('Stats request failed (status: $status). body: $body');
    }
  }

}

final auditApiProvider = Provider<AuditApi>((ref) {
  final client = ref.read(apiClientProvider);
  return AuditApi(client);
});

