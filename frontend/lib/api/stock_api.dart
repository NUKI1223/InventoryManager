import 'api_client.dart';
import '../models/product.dart';
import '../models/stock_transaction.dart';

class StockApi {
  final ApiClient client;

  StockApi(this.client);

  Future<Product> adjustStock(int productId, int change, String type,
      {String? reference, String? note}) async {
    final resp = await client.dio.post(
      '/api/products/$productId/stock/adjust',
      data: {
        'changeAmount': change,
        'type': type,
        'reference': reference,
        'note': note,
      },
    );
    return Product.fromJson(resp.data);
  }

  Future<List<StockTransaction>> fetchTransactions(int productId, int page, int size) async {
    final resp = await client.dio.get(
      '/api/products/$productId/stock/transactions',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
    final list = (resp.data['content'] as List)
        .map((e) => StockTransaction.fromJson(e))
        .toList();
    return list;
  }
}
