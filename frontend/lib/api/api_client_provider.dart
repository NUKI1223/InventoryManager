import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

final storageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());
final dioProvider = Provider<Dio>((ref) => Dio());

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.read(dioProvider);
  final storage = ref.read(storageProvider);
  return ApiClient(dio, storage);
});