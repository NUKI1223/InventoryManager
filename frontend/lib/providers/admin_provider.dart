import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/user.dart';
import '../api/admin_api.dart';
import '../models/password_reset_request.dart';
import 'auth_provider.dart';

final adminApiProvider = Provider<AdminApi>((ref) {
  return AdminApi(ref.read(apiClientProvider));
});


final usersProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final api = ref.read(adminApiProvider);
  return await api.getUsers();
});


final passwordResetsProvider = FutureProvider.autoDispose<List<PasswordResetRequest>>((ref) async {
  final api = ref.read(adminApiProvider);
  return await api.getPasswordResets();
});
