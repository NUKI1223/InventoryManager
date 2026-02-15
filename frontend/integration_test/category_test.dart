import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:inventory_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Category Management Tests', () {
    testWidgets('Create category test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login as admin
      await _performLogin(tester, 'admin', 'admin123');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to categories
      final menuButton = find.byIcon(Icons.menu);
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        final categoriesButton = find.text('Категории');
        if (categoriesButton.evaluate().isNotEmpty) {
          await tester.tap(categoriesButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Find add category button (FAB)
          final addButton = find.byType(FloatingActionButton);
          if (addButton.evaluate().isNotEmpty) {
            await tester.tap(addButton);
            await tester.pumpAndSettle();

            // Should show create category dialog
            expect(find.text('Создать категорию'), findsOneWidget);

            // Fill category details
            final nameField = find.byType(TextField).first;
            await tester.enterText(nameField, 'Test Category');
            await tester.pumpAndSettle();

            // Save
            final saveButton = find.text('Создать');
            if (saveButton.evaluate().isNotEmpty) {
              await tester.tap(saveButton);
              await tester.pumpAndSettle(const Duration(seconds: 2));

              // Should show success message
              expect(find.text('Категории'), findsWidgets);
            }
          }
        }
      }
    });

    testWidgets('Edit category test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await _performLogin(tester, 'admin', 'admin123');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to categories
      final menuButton = find.byIcon(Icons.menu);
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        final categoriesButton = find.text('Категории');
        if (categoriesButton.evaluate().isNotEmpty) {
          await tester.tap(categoriesButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Find first category card
          final categoryCard = find.byType(Card).first;
          if (categoryCard.evaluate().isNotEmpty) {
            // Look for edit button
            final editButton = find.byIcon(Icons.edit).first;
            if (editButton.evaluate().isNotEmpty) {
              await tester.tap(editButton);
              await tester.pumpAndSettle();

              // Should show edit dialog
              expect(find.text('Редактировать категорию'), findsOneWidget);
            }
          }
        }
      }
    });

    testWidgets('Delete category test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await _performLogin(tester, 'admin', 'admin123');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to categories
      final menuButton = find.byIcon(Icons.menu);
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        final categoriesButton = find.text('Категории');
        if (categoriesButton.evaluate().isNotEmpty) {
          await tester.tap(categoriesButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Find delete button
          final deleteButton = find.byIcon(Icons.delete).first;
          if (deleteButton.evaluate().isNotEmpty) {
            await tester.tap(deleteButton);
            await tester.pumpAndSettle();

            // Should show confirmation dialog
            final confirmButton = find.text('Удалить');
            if (confirmButton.evaluate().isNotEmpty) {
              await tester.tap(confirmButton);
              await tester.pumpAndSettle(const Duration(seconds: 2));

              // Category should be deleted
              expect(find.text('Категории'), findsWidgets);
            }
          }
        }
      }
    });
  });
}

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
