import 'package:dio/dio.dart';
import 'package:smart_translator_test/core/config/env.dart';
import 'package:smart_translator_test/core/network/api_endpoint.dart';
import 'package:smart_translator_test/core/storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final SecureStorageService storage;
  final void Function()? onUnauthenticated;

  AuthInterceptor({
    required this.dio,
    required this.storage,
    this.onUnauthenticated,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isAuthEndpoint = options.path.contains(ApiEndpoint.login) ||
        options.path.contains(ApiEndpoint.register);

    if (!isAuthEndpoint) {
      final token = await storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers["Authorization"] = "Bearer $token";
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      if (err.requestOptions.path.contains(ApiEndpoint.refresh) ||
          err.requestOptions.path.contains(ApiEndpoint.login)) {
        await storage.clearToken();
        onUnauthenticated?.call();
        return handler.next(err);
      }

      final refreshToken = await storage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await storage.clearToken();
        onUnauthenticated?.call();
        return handler.next(err);
      }

      try {
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: Env.baseUrl,
            connectTimeout: Env.connectTimeout,
            receiveTimeout: Env.receiveTimeout,
            headers: {"Content-Type": "application/json"},
          ),
        );

        final response = await refreshDio.post(
          ApiEndpoint.refresh,
          data: {"refreshToken": refreshToken},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = response.data["data"];
          final newAccessToken = responseData["token"] as String;
          final newRefreshToken =
              (responseData["refreshToken"] ?? refreshToken) as String;

          await storage.saveToken(newAccessToken, newRefreshToken);

          final originalOptions = err.requestOptions;
          originalOptions.headers["Authorization"] = "Bearer $newAccessToken";

          final retryResponse = await dio.fetch(originalOptions);
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        await storage.clearToken();
        onUnauthenticated?.call();
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}
