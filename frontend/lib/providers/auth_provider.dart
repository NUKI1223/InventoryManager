import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/auth_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final storageProvider = Provider((ref) => FlutterSecureStorage());
final dioProvider = Provider((ref) => Dio());

final apiClientProvider = Provider((ref) {
  return ApiClient(ref.read(dioProvider), ref.read(storageProvider));
});

final authApiProvider = Provider((ref) => AuthApi(ref.read(apiClientProvider)));


final isAdminProvider = FutureProvider<bool>((ref) async {
  final token = ref.watch(authNotifierProvider);
  if (token == null) return false;

  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final role = decodedToken['role'] ?? '';
    return role.toUpperCase() == 'ADMIN';
  } catch (e) {
    return false;
  }
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier(ref.read(authApiProvider), ref.read(storageProvider));
});

class AuthNotifier extends StateNotifier<String?> {
  final AuthApi api;
  final FlutterSecureStorage storage;

  AuthNotifier(this.api, this.storage) : super(null) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final tok = await storage.read(key: 'jwt');
    state = tok;
  }

  Future<void> login(String username, String password) async {
    final tok = await api.login(username, password);
    await storage.write(key: 'jwt', value: tok);
    state = tok;
  }

  Future<void> register(String username, String password, String fullName) async {
    final tok = await api.register(username, password, fullName);
    await storage.write(key: 'jwt', value: tok);
    state = tok;
  }

  Future<void> logout() async {
    await storage.delete(key: 'jwt');
    state = null;
  }


  String? getUserRole() {
    if (state == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(state!);
      return decodedToken['role'];
    } catch (e) {
      return null;
    }
  }

  bool isAdmin() {
    final role = getUserRole();
    return role?.toUpperCase() == 'ADMIN';
  }
}