import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'routes.dart';
import 'providers/theme_provider.dart';
import 'providers/websocket_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  String? _previousToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupWebSocket();
    });
  }

  void _setupWebSocket() {
    final wsService = ref.read(websocketServiceProvider);

    wsService.onNotificationReceived = (notification) {
      ref.read(realtimeNotificationProvider.notifier).state = notification;
      // Обновить счётчик непрочитанных
      ref.invalidate(unreadCountProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notification['title'] ?? 'Новое уведомление'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Открыть',
              textColor: Colors.white,
              onPressed: () {
                ref.read(routerProvider).push('/notifications');
              },
            ),
          ),
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final token = ref.watch(authNotifierProvider);

    // Подключать/отключать WebSocket при изменении токена
    if (token != _previousToken) {
      _previousToken = token;
      final wsService = ref.read(websocketServiceProvider);
      if (token != null) {
        wsService.connect().then((_) {
          ref.read(websocketConnectionProvider.notifier).state = wsService.isConnected;
        });
      } else {
        wsService.disconnect();
        ref.read(websocketConnectionProvider.notifier).state = false;
      }
    }

    return MaterialApp.router(
      title: 'Inventory App',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}