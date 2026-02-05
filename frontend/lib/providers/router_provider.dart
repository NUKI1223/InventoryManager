import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/login_screen.dart';
import '../ui/product_list_screen.dart';
import '../ui/product_detail_screen.dart';
import 'auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final token = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: token == null ? '/' : '/products',
    routes: [
      GoRoute(path: '/', builder: (ctx, state) => const LoginScreen()),
      GoRoute(path: '/products', builder: (ctx, state) => const ProductListScreen()),
      GoRoute(
        path: '/products/:id',
        builder: (ctx, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProductDetailScreen(productId: id);
        },
      ),
    ],
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/';
      final loggedIn = token != null;

      if (!loggedIn && !loggingIn) return '/';
      if (loggedIn && loggingIn) return '/products';
      return null;
    },
  );
});
