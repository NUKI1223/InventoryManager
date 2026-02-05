import 'package:go_router/go_router.dart';
import 'ui/login_screen.dart';
import 'ui/register_screen.dart';
import 'ui/product_list_screen.dart';
import 'ui/product_detail_screen.dart';
import 'ui/add_product_screen.dart';
import 'ui/admin_panel_screen.dart';
import 'ui/forgot_password_screen.dart';
import 'ui/category_screen.dart';
import 'providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        // Check if trying to access admin route
        if (state.matchedLocation.startsWith('/admin')) {
          final authNotifier = ref.read(authNotifierProvider.notifier);
          if (!authNotifier.isAdmin()) {
            // Not admin, redirect to products
            return '/products';
          }
        }
        return null; // No redirect
      },
      routes: [
      GoRoute(path: '/', builder: (ctx, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (ctx, state) => const RegisterScreen()),
    GoRoute(path: '/products', builder: (ctx, state) => const ProductListScreen()),
    GoRoute(path: '/forgot-password', builder: (ctx, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/admin', builder: (ctx, state) => const AdminPanelScreen()),
    GoRoute(path: '/categories', builder: (ctx, state) => const CategoryScreen()),
    GoRoute(path: '/products/add', builder: (ctx, state) => const AddProductScreen()),
    GoRoute(
      path: '/products/:id',
      builder: (ctx, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ProductDetailScreen(productId: id);
      },
    ),
  ],
);});