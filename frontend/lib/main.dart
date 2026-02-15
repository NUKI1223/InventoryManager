import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'routes.dart';
import 'providers/theme_provider.dart';
import 'providers/websocket_provider.dart';


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
  @override
  void initState() {
    super.initState();
    // Initialize WebSocket connection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWebSocket();
    });
  }

  void _initWebSocket() {
    final wsService = ref.read(websocketServiceProvider);

    // Set up notification callback
    wsService.onNotificationReceived = (notification) {
      ref.read(realtimeNotificationProvider.notifier).state = notification;

      // Show snackbar for new notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notification['title'] ?? 'New notification'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to notifications screen
              },
            ),
          ),
        );
      }
    };

    // Connect to WebSocket
    wsService.connect().then((_) {
      ref.read(websocketConnectionProvider.notifier).state = wsService.isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

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