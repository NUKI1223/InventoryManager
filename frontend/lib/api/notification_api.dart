import '../api/api_client.dart';
import '../models/notification.dart';

class NotificationApi {
  final ApiClient client;

  NotificationApi(this.client);

  Future<Map<String, dynamic>> getNotifications({int page = 0, int size = 20}) async {
    final response = await client.get('/api/notifications?page=$page&size=$size');
    return response.data;
  }

  Future<int> getUnreadCount() async {
    final response = await client.get('/api/notifications/unread-count');
    return response.data as int;
  }

  Future<NotificationModel> markAsRead(int id) async {
    final response = await client.put('/api/notifications/$id/read');
    return NotificationModel.fromJson(response.data);
  }

  Future<void> deleteNotification(int id) async {
    await client.delete('/api/notifications/$id');
  }

  Future<void> deleteAll() async {
    await client.delete('/api/notifications');
  }
}
