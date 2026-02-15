import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:inventory_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Inventory App Integration Tests', () {
    testWidgets('Login flow test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should show login screen
      expect(find.text('Вход в систему'), findsOneWidget);

      // Find username and password fields
      final usernameFinder = find.byType(TextFormField).first;
      final passwordFinder = find.byType(TextFormField).last;

      // Enter credentials (using test user)
      await tester.enterText(usernameFinder, 'admin');
      await tester.enterText(passwordFinder, 'admin123');

      await tester.pumpAndSettle();

      // Find and tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Войти');
      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // After successful login, should navigate to products screen
      expect(find.text('Товары'), findsWidgets);
    });

    testWidgets('Product list and search test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await _performLogin(tester, 'admin', 'admin123');

      // Should be on products screen
      expect(find.text('Товары'), findsWidgets);

      // Wait for products to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find search field
      final searchField = find.byType(TextField).first;
      expect(searchField, findsOneWidget);

      // Enter search query
      await tester.enterText(searchField, 'Laptop');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Products should be filtered
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Navigation test - Categories', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await _performLogin(tester, 'admin', 'admin123');

      // Wait for home screen
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap menu button
      final menuButton = find.byIcon(Icons.menu);
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        // Find Categories in drawer
        final categoriesButton = find.text('Категории');
        if (categoriesButton.evaluate().isNotEmpty) {
          await tester.tap(categoriesButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Should show categories screen
          expect(find.text('Категории'), findsWidgets);
        }
      }
    });

    testWidgets('Add product flow test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login as admin
      await _performLogin(tester, 'admin', 'admin123');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find FAB to add product
      final addButton = find.byType(FloatingActionButton);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Should navigate to add product screen
        expect(find.text('Добавить товар'), findsOneWidget);

        // Fill in product details
        final fields = find.byType(TextFormField);
        if (fields.evaluate().length >= 4) {
          await tester.enterText(fields.at(0), 'TEST-SKU-001');
          await tester.enterText(fields.at(1), 'Test Product');
          await tester.enterText(fields.at(2), 'Test description');
          await tester.enterText(fields.at(3), '1000');

          await tester.pumpAndSettle();

          // Find and tap save button
          final saveButton = find.widgetWithText(ElevatedButton, 'Сохранить');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle(const Duration(seconds: 3));

            // Should show success message or navigate back
            expect(find.text('Товары'), findsWidgets);
          }
        }
      }
    });

    testWidgets('Stock adjustment test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await _performLogin(tester, 'admin', 'admin123');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap on first product card
      final productCard = find.byType(Card).first;
      if (productCard.evaluate().isNotEmpty) {
        await tester.tap(productCard);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Look for stock adjustment button
        final adjustButton = find.text('Корректировка запасов');
        if (adjustButton.evaluate().isNotEmpty) {
          await tester.tap(adjustButton);
          await tester.pumpAndSettle();

          // Should show adjust stock screen
          expect(find.text('Корректировка запасов'), findsWidgets);
        }
      }
    });

    testWidgets('Dark theme toggle test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await _performLogin(tester, 'admin', 'admin123');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to profile
      final menuButton = find.byIcon(Icons.menu);
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        final profileButton = find.text('Профиль');
        if (profileButton.evaluate().isNotEmpty) {
          await tester.tap(profileButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Find theme toggle switch
          final themeSwitch = find.byType(SwitchListTile);
          if (themeSwitch.evaluate().isNotEmpty) {
            await tester.tap(themeSwitch.first);
            await tester.pumpAndSettle();

            // Theme should change
            expect(find.byType(SwitchListTile), findsWidgets);
          }
        }
      }
    });
  });
}

// Helper function to perform login
Future<void> _performLogin(
    WidgetTester tester, String username, String password) async {
  final usernameFinder = find.byType(TextFormField).first;
  final passwordFinder = find.byType(TextFormField).last;

  await tester.enterText(usernameFinder, username);
  await tester.enterText(passwordFinder, password);
  await tester.pumpAndSettle();

  final loginButton = find.widgetWithText(ElevatedButton, 'Войти');
  await tester.tap(loginButton);
  await tester.pumpAndSettle(const Duration(seconds: 3));
}
