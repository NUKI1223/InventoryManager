import 'package:dio/dio.dart';


String friendlyError(Object e) {
  try {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;


// Authorization errors -> friendly message
      if (status == 401 || status == 403) return 'Invalid login or password';


// Server errors
      if (status != null && status >= 500) return 'Server error. Please try again later.';


// If server sent structured message
      if (data is Map) {
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
      }


      if (data is String && data.isNotEmpty) return data;


      return 'Request failed (status: ${status ?? 'unknown'})';
    }


// Fallback for other exceptions
    return e.toString();
  } catch (_) {
    return 'An unexpected error occurred';
  }
}