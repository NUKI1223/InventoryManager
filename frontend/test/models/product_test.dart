import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Product should be created from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'sku': 'TEST-001',
        'name': 'Test Product',
        'price': 99.99,
        'currentStock': 100,
        'category': {
          'id': 1,
          'name': 'Electronics',
        },
        'imagePath': '/images/test.jpg'
      };

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.id, equals(1));
      expect(product.sku, equals('TEST-001'));
      expect(product.name, equals('Test Product'));
      expect(product.price, equals(99.99));
      expect(product.currentStock, equals(100));
      expect(product.categoryId, equals(1));
      expect(product.categoryName, equals('Electronics'));
      expect(product.imagePath, equals('/images/test.jpg'));
    });

    test('Product should be converted to JSON', () {
      // Arrange
      final product = Product(
        id: 1,
        sku: 'TEST-001',
        name: 'Test Product',
        price: 99.99,
        currentStock: 100,
        categoryId: 1,
        categoryName: 'Electronics',
      );

      // Act
      final json = product.toJson();

      // Assert
      expect(json['sku'], equals('TEST-001'));
      expect(json['name'], equals('Test Product'));
      expect(json['price'], equals(99.99));
      expect(json['currentStock'], equals(100));
      expect(json['categoryId'], equals(1));
    });

    test('Product with null category should handle JSON correctly', () {
      // Arrange
      final json = {
        'id': 1,
        'sku': 'TEST-001',
        'name': 'Test Product',
        'price': 99.99,
        'currentStock': 100,
      };

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.id, equals(1));
      expect(product.categoryId, isNull);
      expect(product.categoryName, isNull);
    });

    test('Product copyWith should create new instance with updated values', () {
      // Arrange
      final original = Product(
        id: 1,
        sku: 'TEST-001',
        name: 'Original Product',
        price: 99.99,
        currentStock: 100,
      );

      // Act
      final updated = original.copyWith(
        name: 'Updated Product',
        price: 149.99,
      );

      // Assert
      expect(updated.id, equals(1));
      expect(updated.name, equals('Updated Product'));
      expect(updated.price, equals(149.99));
      expect(updated.sku, equals('TEST-001')); // Unchanged
      expect(updated.currentStock, equals(100)); // Unchanged
    });

    test('Product imageUrl should return empty string when imagePath is null', () {
      // Arrange
      final product = Product(
        id: 1,
        sku: 'TEST-001',
        name: 'Test Product',
        price: 99.99,
        currentStock: 100,
      );

      // Act & Assert
      expect(product.imageUrl, equals(''));
    });

    test('Product imageUrl should return imagePath when it exists', () {
      // Arrange
      final product = Product(
        id: 1,
        sku: 'TEST-001',
        name: 'Test Product',
        price: 99.99,
        currentStock: 100,
        imagePath: '/images/product.jpg',
      );

      // Act & Assert
      expect(product.imageUrl, equals('/images/product.jpg'));
    });
  });
}
