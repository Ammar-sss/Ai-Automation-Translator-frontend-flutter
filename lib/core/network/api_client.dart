import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:smart_translator/core/network/token_storage.dart';

import '../config/env.dart';
import 'auth_interceptor.dart';

/// Builds and holds the configured dio instance.
class ApiClient {
  ApiClient({required TokenStorage tokenStorage, Dio? dio})
    : dio = dio ?? _build(tokenStorage);

  final Dio dio;

  static Dio _build(TokenStorage tokenStorage) {
    final d = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: Env.connectTimeout,
        receiveTimeout: Env.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Order matters: auth first (attach token), logger second (log the final
    // request). On the way back out, the logger runs before error handling.
    d.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage, dio: d));
    d.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
      ),
    );

    return d;
  }
}
