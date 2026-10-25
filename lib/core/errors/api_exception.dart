import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({this.statusCode, this.message = 'Something went wrong'});

  final int? statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Converts a dio error into an [ApiException], reading the backend envelope
/// `{statusCode, message, data}` for a friendly message.
ApiException mapDioError(DioException e) {
  final statusCode = e.response?.statusCode;
  var message = 'Something went wrong';
  final data = e.response?.data;
  if (data is Map<String, dynamic> && data['message'] is String) {
    message = data['message'] as String;
  }
  return ApiException(statusCode: statusCode, message: message);
}
