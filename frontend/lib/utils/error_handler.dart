import 'package:dio/dio.dart';


String friendlyError(Object e) {
  try {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      // Сначала читаем сообщение из тела ответа
      if (data is Map) {
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
      }
      if (data is String && data.isNotEmpty) return data;

      // Фолбэк по статус-коду
      if (status == 401 || status == 403) return 'Неверный логин или пароль';
      if (status == 404) return 'Не найдено';
      if (status != null && status >= 500) return 'Ошибка сервера. Попробуйте позже.';

      if (status == null) return 'Нет соединения с сервером';
      return 'Ошибка запроса (статус: $status)';
    }

    return e.toString();
  } catch (_) {
    return 'Неожиданная ошибка';
  }
}