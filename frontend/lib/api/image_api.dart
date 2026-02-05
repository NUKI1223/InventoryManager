import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/product.dart';
import 'package:path/path.dart';

class ImageApi {
  final ApiClient api;
  ImageApi(this.api);

  Future<Product> uploadImage(int productId, File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: basename(file.path)),
    });

    final response = await api.dio.post(
      '/api/products/$productId/uploadImage',
      data: formData,
    );

    return Product.fromJson(response.data);
  }
}
