import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/utils/error_handler.dart';

void main() {
  group('friendlyError', () {
    test('возвращает message из тела ответа', () {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        statusCode: 401,
        data: {'message': 'Неверный логин или пароль'},
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      // Act
      final result = friendlyError(error);

      // Assert
      expect(result, 'Неверный логин или пароль');
    });

    test('возвращает error из тела ответа если нет message', () {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 409,
        data: {'error': 'Пользователь с таким логином уже существует'},
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      // Act
      final result = friendlyError(error);

      // Assert
      expect(result, 'Пользователь с таким логином уже существует');
    });

    test('возвращает "Неверный логин или пароль" для статуса 401 без тела', () {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        statusCode: 401,
        data: null,
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      // Act
      final result = friendlyError(error);

      // Assert
      expect(result, 'Неверный логин или пароль');
    });

    test('возвращает "Нет соединения с сервером" когда response равен null', () {
      // Arrange — нет response означает что сервер недоступен
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/products'),
        response: null,
        type: DioExceptionType.connectionError,
      );

      // Act
      final result = friendlyError(error);

      // Assert
      expect(result, 'Нет соединения с сервером');
    });

    test('возвращает "Ошибка сервера" для статуса 500', () {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/api/products'),
        statusCode: 500,
        data: null,
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/products'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      // Act
      final result = friendlyError(error);

      // Assert
      expect(result, contains('Ошибка сервера'));
    });

    test('возвращает строку для обычных исключений не связанных с Dio', () {
      // Arrange
      final error = Exception('Обычная ошибка');

      // Act
      final result = friendlyError(error);

      // Assert
      expect(result, isNotEmpty);
    });

    test('возвращает "Не найдено" для статуса 404', () {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/api/products/99999'),
        statusCode: 404,
        data: null,
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/products/99999'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      // Act
      final result = friendlyError(error);

      // Assert
      expect(result, 'Не найдено');
    });
  });
}
