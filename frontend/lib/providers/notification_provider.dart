import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/notification_api.dart';
import '../models/notification.dart';
import 'auth_provider.dart';

final notificationApiProvider = Provider<NotificationApi>((ref) {
  return NotificationApi(ref.watch(apiClientProvider));
});

final notificationListProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final api = ref.watch(notificationApiProvider);
  final response = await api.getNotifications();
  final content = response['content'] as List;
  return content.map((e) => NotificationModel.fromJson(e)).toList();
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final api = ref.watch(notificationApiProvider);
  return await api.getUnreadCount();
});
