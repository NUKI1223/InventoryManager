import 'api_client.dart';
import '../models/user.dart';
import '../models/password_reset_request.dart';

class AdminApi {
  final ApiClient client;

  AdminApi(this.client);

  Future<List<User>> getUsers() async {
    final res = await client.get('/api/admin/users');
    return (res.data as List).map((json) => User.fromJson(json)).toList();
  }

  Future<User> updateUser(int userId, Map<String, dynamic> data) async {
    final res = await client.put('/api/admin/users/$userId', data: data);
    return User.fromJson(res.data);
  }

  Future<void> deleteUser(int userId) async {
    await client.delete('/api/admin/users/$userId');
  }

  Future<List<PasswordResetRequest>> getPasswordResets() async {
    final res = await client.get('/api/admin/password-resets');
    return (res.data as List)
        .map((json) => PasswordResetRequest.fromJson(json))
        .toList();
  }

  Future<void> resetPassword(int userId, String newPassword) async {
    await client.post('/api/admin/reset-password', data: {
      'userId': userId,
      'newPassword': newPassword,
    });
  }

  Future<void> completeResetRequest(int requestId) async {
    await client.post('/api/admin/password-resets/$requestId/complete');
  }

  Future<void> rejectResetRequest(int requestId) async {
    await client.post('/api/admin/password-resets/$requestId/reject');
  }

  Future<void> forgotPassword(String username) async {
    await client.post('/api/auth/forgot-password', data: {
      'username': username,
    });
  }
}
