import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'api_client.dart';
import '../models/product.dart';
import '../models/page_result.dart';
import '../models/import_report.dart';

class ProductApi {
  final ApiClient api;

  ProductApi(this.api);


  Future<PageResult<Product>> getProductsPage({
    String? q,
    String? sort,
    int? categoryId,
    int page = 0,
    int size = 10,
  }) async {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;
    if (categoryId != null) params['categoryId'] = categoryId;

    final res = await api.dio.get('/api/products', queryParameters: params);
    final data = res.data as Map<String, dynamic>;
    return PageResult.fromJson(data, (m) => Product.fromJson(m));
  }


  Future<List<Product>> getProducts({
    int page = 0,
    int size = 10,
  }) async {
    final pageRes = await getProductsPage(page: page, size: size);
    return pageRes.content;
  }

  Future<void> deleteProduct(int productId) async {
    final response = await api.dio.delete('/api/products/$productId');
    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      throw Exception('Delete failed, status=${response.statusCode}');
    }
  }

  Future<Uint8List> exportProducts({String? q, int page = 0, int size = 500}) async {
    final params = <String, dynamic>{'page': page.toString(), 'size': size.toString()};
    if (q != null && q.isNotEmpty) params['q'] = q;
    final response = await api.dio.get<List<int>>('/api/products/export',
        queryParameters: params, options: Options(responseType: ResponseType.bytes));
    final bytes = Uint8List.fromList(response.data ?? <int>[]);
    return bytes;
  }

  Future<ImportReport> importProducts(String filePath, {String mode = 'UPSERT'}) async {
    final fileName = basename(filePath);
    final mp = await MultipartFile.fromFile(filePath, filename: fileName);
    final form = FormData.fromMap({'file': mp, 'mode': mode});
    final res = await api.dio.post('/api/products/import', data: form);
    if (res.data is Map<String, dynamic>) {
      return ImportReport.fromJson(Map<String, dynamic>.from(res.data));
    } else if (res.data is Map) {
      return ImportReport.fromJson(Map<String, dynamic>.from(res.data as Map));
    } else {
      throw Exception('Unexpected import response format');
    }
  }

  Future<Product> getProductDetail(int id) async {
    final response = await api.dio.get('/api/products/$id');
    return Product.fromJson(response.data);
  }

  Future<Product> addProduct(Product p) async {
    final response = await api.dio.post('/api/products', data: p.toJson());
    return Product.fromJson(response.data);
  }

  Future<Product> uploadImage(int productId, File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: basename(file.path)),
    });
    final res = await api.dio.post('/api/products/$productId/uploadImage', data: formData);
    return Product.fromJson(res.data);
  }

  Future<Product> saveImagePath(int productId, String imagePath) async {
    final res = await api.post('/api/products/$productId/saveImagePath',
        data: {'imagePath': imagePath});
    return Product.fromJson(res.data);
  }

  Future<Product> adjustStock(int productId, int delta) async {
    final res = await api.post('/api/products/$productId/stock/adjust', data: {'delta': delta});
    return Product.fromJson(res.data);
  }
}