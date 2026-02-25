import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_app/ui/login_screen.dart';

Widget _buildTestApp() {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/products', builder: (_, __) => const Scaffold(body: Text('Товары'))),
      GoRoute(path: '/register', builder: (_, __) => const Scaffold(body: Text('Регистрация'))),
      GoRoute(path: '/forgot-password', builder: (_, __) => const Scaffold(body: Text('Восстановление'))),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('отображает заголовок и форму входа', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Проверяем наличие заголовка
      expect(find.text('Добро пожаловать!'), findsOneWidget);
    });

    testWidgets('содержит поля логина и пароля', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Логин-экран использует TextField
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('содержит кнопку "Войти"', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Войти'), findsOneWidget);
    });

    testWidgets('содержит ссылку на регистрацию', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Регистрация'), findsOneWidget);
    });

    testWidgets('показывает ошибку при пустом логине', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Нажимаем "Войти" без ввода данных
      await tester.tap(find.text('Войти'));
      await tester.pump();

      // Должна появиться ошибка валидации логина
      expect(find.text('Введите имя пользователя'), findsOneWidget);
    });

    testWidgets('можно ввести текст в поле логина', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Находим TextField с подсказкой "Введите логин"
      final loginField = find.ancestor(
        of: find.text('Введите логин'),
        matching: find.byType(TextField),
      );
      await tester.enterText(loginField, 'testuser');
      await tester.pump();

      expect(find.text('testuser'), findsOneWidget);
    });
  });
}
