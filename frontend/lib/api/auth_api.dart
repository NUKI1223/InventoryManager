import 'api_client.dart';

class AuthApi {
  final ApiClient client;

  AuthApi(this.client);

  Future<String> login(String username, String password) async {
    final res = await client.post('/api/auth/login', data: {'username': username, 'password': password});
    return res.data['token'];
  }

  Future<String> register(String username, String password, String fullName) async {
    final res = await client.post('/api/auth/register', data: {
      'username': username,
      'password': password,
      'fullName': fullName,
    });
    return res.data['token'];
  }
}
