import 'package:dio/dio.dart';
import '../api/api_client.dart';

class ProfileApi {
  final ApiClient client;

  ProfileApi(this.client);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await client.get('/api/profile');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String fullName,
  }) async {
    final response = await client.put('/api/profile', data: {
      'username': username,
      'fullName': fullName,
    });
    return response.data;
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await client.put('/api/profile/password', data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }
}
