import 'api_client.dart';
import '../models/category.dart';

class CategoryApi {
  final ApiClient client;

  CategoryApi(this.client);

  Future<List<Category>> getAll() async {
    final res = await client.get('/api/categories');
    return (res.data as List).map((json) => Category.fromJson(json)).toList();
  }

  Future<Category> create(String name, String? description) async {
    final res = await client.post('/api/categories', data: {
      'name': name,
      'description': description,
    });
    return Category.fromJson(res.data);
  }

  Future<Category> update(int id, String name, String? description) async {
    final res = await client.put('/api/categories/$id', data: {
      'name': name,
      'description': description,
    });
    return Category.fromJson(res.data);
  }

  Future<void> delete(int id) async {
    await client.delete('/api/categories/$id');
  }
}
