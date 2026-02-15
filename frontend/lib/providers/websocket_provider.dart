import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';

final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();

  // Auto-cleanup on dispose
  ref.onDispose(() {
    service.disconnect();
  });

  return service;
});

// Provider to track connection status
final websocketConnectionProvider = StateProvider<bool>((ref) => false);

// Provider for real-time notifications
final realtimeNotificationProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
