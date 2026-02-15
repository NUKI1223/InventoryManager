import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WebSocketService {
  static const String wsUrl = 'http://localhost:9000/ws';
  StompClient? _stompClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Function(Map<String, dynamic>)? onNotificationReceived;

  Future<void> connect() async {
    final userId = await _getUserId();
    if (userId == null) return;

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (StompFrame frame) {
          print('WebSocket connected');

          // Subscribe to user-specific notifications
          _stompClient?.subscribe(
            destination: '/topic/notifications/$userId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final notification = jsonDecode(frame.body!);
                print('Received notification: $notification');
                onNotificationReceived?.call(notification);
              }
            },
          );
        },
        onWebSocketError: (dynamic error) {
          print('WebSocket error: $error');
        },
        onStompError: (StompFrame frame) {
          print('Stomp error: ${frame.body}');
        },
        onDisconnect: (StompFrame frame) {
          print('WebSocket disconnected');
        },
      ),
    );

    _stompClient?.activate();
  }

  Future<String?> _getUserId() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return null;

    // Decode JWT to get userId (simple base64 decode of payload)
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = jsonDecode(decoded);

      return data['userId']?.toString();
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }

  bool get isConnected => _stompClient?.connected ?? false;
}
