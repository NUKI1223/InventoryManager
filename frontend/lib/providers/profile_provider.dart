import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/profile_api.dart';
import '../api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final profileApiProvider = Provider<ProfileApi>((ref) {
  return ProfileApi(ApiClient(Dio(), const FlutterSecureStorage()));
});

final profileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(profileApiProvider);
  return await api.getProfile();
});
