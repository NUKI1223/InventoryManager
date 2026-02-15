import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage;
  late final CacheStore cacheStore;
  late final DioCacheInterceptor cacheInterceptor;

  ApiClient(this.dio, this.storage) {
    dio.options.baseUrl = 'http://localhost:9000';

    // Setup cache
    cacheStore = MemCacheStore();
    cacheInterceptor = DioCacheInterceptor(
      options: CacheOptions(
        store: cacheStore,
        policy: CachePolicy.request,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(minutes: 10),
        priority: CachePriority.normal,
        cipher: null,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        allowPostMethod: false,
      ),
    );

    // Add interceptors
    dio.interceptors.add(cacheInterceptor);
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'jwt');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    // Performance optimizations
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.sendTimeout = const Duration(seconds: 10);
  }

  Future<Response> get(String path, {bool forceRefresh = false}) async {
    return dio.get(
      path,
      options: forceRefresh
          ? CacheOptions(
              policy: CachePolicy.refresh,
              store: cacheStore,
            ).toOptions()
          : null,
    );
  }

  Future<Response> post(String path, {dynamic data}) async =>
      dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) async =>
      dio.put(path, data: data);

  Future<Response> delete(String path) async => dio.delete(path);

  // Clear cache
  Future<void> clearCache() async {
    await cacheStore.clean();
  }

  // Get cache info
  Future<Map<String, dynamic>> getCacheInfo() async {
    return {
      'exists': await cacheStore.exists(dio.options.baseUrl),
    };
  }
}
