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
              // Render free tier can take 30-50s to wake up from sleep
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 60),
            ),
          );

  /// Returns true if server responds with 200 OK, otherwise false.
  Future<bool> isServerAlive() async {
    try {
      final response = await _dio.get(ApiEndpoint.health);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
