import '../api/api_client.dart';
import '../models/product.dart';

class DashboardApi {
  final ApiClient client;

  DashboardApi(this.client);

  Future<List<Product>> getLowStockProducts({int threshold = 5}) async {
    final response = await client.get('/api/products/low-stock?threshold=$threshold');
    return (response.data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getZeroStockProducts() async {
    final response = await client.get('/api/products/zero-stock');
    return (response.data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 10}) async {
    final response = await client.get('/api/stats/recent-transactions?limit=$limit');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getStatsByCategory() async {
    final response = await client.get('/api/stats/by-category');
    return List<Map<String, dynamic>>.from(response.data);
  }
}
