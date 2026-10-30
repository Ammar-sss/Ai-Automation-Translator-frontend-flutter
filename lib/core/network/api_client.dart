import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:smart_translator/core/network/token_storage.dart';

import '../config/env.dart';
import 'auth_interceptor.dart';

/// Builds and holds the configured dio instance.
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    VoidCallback? onSessionExpired,
    Dio? dio,
  }) : dio = dio ?? _build(tokenStorage, onSessionExpired: onSessionExpired);

  final Dio dio;

  static Dio _build(TokenStorage tokenStorage, {VoidCallback? onSessionExpired}) {
    final d = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: Env.connectTimeout,
        receiveTimeout: Env.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Order matters: auth first (attach token), logger second.
    d.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        dio: d,
        onSessionExpired: onSessionExpired,
      ),
    );

    if (kDebugMode) {
      d.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
        ),
      );
    }

    return d;
  }
}
