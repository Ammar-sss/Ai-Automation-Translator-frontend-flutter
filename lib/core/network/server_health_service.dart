import 'package:dio/dio.dart';

import '../config/env.dart';
import 'api_endpoint.dart';

class ServerHealthService {
  final Dio _dio;

  ServerHealthService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: Env.baseUrl,
              // Fast 8-second timeout for 10s automatic health checks
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: {
                "Accept": "application/json, application/vnd.spring-boot.actuator.v3+json, */*",
              },
            ),
          );

  /// Returns true if server responds with 200 OK or status UP, otherwise false.
  Future<bool> isServerAlive({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get(
        ApiEndpoint.health,
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          final status = response.data['status']?.toString().toUpperCase();
          return status == 'UP' || status == null;
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
