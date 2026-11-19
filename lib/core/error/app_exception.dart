import 'package:dio/dio.dart';

/// Base custom exception for the application
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Specialized exception for network and API errors with automatic mapping
class ApiErrorHandler {
  ApiErrorHandler._();

  /// Converts any [DioException] or dynamic error into a clean, human-readable [AppException]
  static AppException handle(
    dynamic error, {
    String fallback = 'An unexpected error occurred. Please try again.',
  }) {
    if (error is DioException) {
      // 1. Connection / Timeout errors (e.g. Render server cold start or no internet)
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return const AppException(
          'Server is waking up or unreachable. Please try again in a moment.',
        );
      }

      // 2. Extract error message from backend response if available
      final responseData = error.response?.data;
      final statusCode = error.response?.statusCode;

      if (responseData is Map<String, dynamic>) {
        if (responseData['message'] is String &&
            (responseData['message'] as String).isNotEmpty) {
          return AppException(
            responseData['message'] as String,
            statusCode: statusCode,
          );
        }
      }

      // 3. Fallbacks based on common HTTP status codes
      switch (statusCode) {
        case 400:
          return AppException(
            'Bad request. Please check your input.',
            statusCode: statusCode,
          );
        case 401:
          return AppException(
            'Session expired or unauthorized. Please log in again.',
            statusCode: statusCode,
          );
        case 403:
          return AppException('Access forbidden.', statusCode: statusCode);
        case 404:
          return AppException('Resource not found.', statusCode: statusCode);
        case 409:
          return AppException(
            'Conflict occurred. Resource already exists.',
            statusCode: statusCode,
          );
        case 500:
        case 502:
        case 503:
          return AppException(
            'Server error. Please try again later.',
            statusCode: statusCode,
          );
      }

      return AppException(fallback, statusCode: statusCode);
    }

    if (error is AppException) {
      return error;
    }

    return AppException(
      error?.toString().replaceAll('Exception: ', '') ?? fallback,
    );
  }
}
