import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/models/notification.dart';

void main() {
  group('NotificationModel', () {
    test('fromJson создаёт корректную модель с полным набором данных', () {
      // Arrange
      final json = {
        'id': 1,
        'title': 'Низкий запас товара',
        'message': 'Товар "Ноутбук" имеет низкий запас: 3 шт.',
        'type': 'LOW_STOCK',
        'isRead': false,
        'createdAt': '2026-02-25T10:00:00',
        'product': {'id': 42, 'name': 'Ноутбук'},
      };

      // Act
      final model = NotificationModel.fromJson(json);

      // Assert
      expect(model.id, 1);
      expect(model.title, 'Низкий запас товара');
      expect(model.message, 'Товар "Ноутбук" имеет низкий запас: 3 шт.');
      expect(model.type, 'LOW_STOCK');
      expect(model.isRead, false);
      expect(model.productId, 42);
      expect(model.productName, 'Ноутбук');
    });

    test('fromJson корректно обрабатывает null product', () {
      // Arrange
      final json = {
        'id': 2,
        'title': 'Системное уведомление',
        'message': 'Резервная копия создана',
        'type': 'SYSTEM',
        'isRead': true,
        'createdAt': '2026-02-25T12:00:00',
        'product': null,
      };

      // Act
      final model = NotificationModel.fromJson(json);

      // Assert
      expect(model.id, 2);
      expect(model.type, 'SYSTEM');
      expect(model.isRead, true);
      expect(model.productId, isNull);
      expect(model.productName, isNull);
    });

    test('fromJson устанавливает isRead в false по умолчанию', () {
      // Arrange — нет поля isRead
      final json = {
        'id': 3,
        'title': 'Тест',
        'message': 'Тестовое уведомление',
        'type': 'SYSTEM',
        'createdAt': '2026-02-25T15:00:00',
      };

      // Act
      final model = NotificationModel.fromJson(json);

      // Assert
      expect(model.isRead, false);
    });

    test('fromJson устанавливает тип SYSTEM по умолчанию', () {
      // Arrange — нет поля type
      final json = {
        'id': 4,
        'title': 'Без типа',
        'message': 'Уведомление без типа',
        'createdAt': '2026-02-25T15:00:00',
      };

      // Act
      final model = NotificationModel.fromJson(json);

      // Assert
      expect(model.type, 'SYSTEM');
    });

    test('toJson возвращает корректный Map', () {
      // Arrange
      final json = {
        'id': 5,
        'title': 'Тест сериализации',
        'message': 'Проверка toJson',
        'type': 'LOW_STOCK',
        'isRead': false,
        'createdAt': '2026-02-25T16:00:00',
        'product': {'id': 10, 'name': 'Принтер'},
      };

      // Act
      final model = NotificationModel.fromJson(json);
      final result = model.toJson();

      // Assert
      expect(result['id'], 5);
      expect(result['title'], 'Тест сериализации');
      expect(result['type'], 'LOW_STOCK');
      expect(result['productId'], 10);
    });
  });
}
