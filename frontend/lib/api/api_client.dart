import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage;

  ApiClient(this.dio, this.storage) {
    dio.options.baseUrl = 'http://10.27.190.82:9000';
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'jwt');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<Response> get(String path) async => dio.get(path);
  Future<Response> post(String path, {dynamic data}) async => dio.post(path, data: data);
  Future<Response> put(String path, {dynamic data}) async => dio.put(path, data: data);
  Future<Response> delete(String path) async => dio.delete(path);
}
