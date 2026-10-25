import 'package:dio/dio.dart';

import '../config/api_endpoints.dart';
import '../config/app_constants.dart';
import '../config/env.dart';
import '../../features/auth/data/models/login_response.dart';
import 'token_storage.dart';

/// Adds the Bearer token to authenticated requests and transparently
/// refreshes the access token once when a 401 comes back.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this._tokenStorage, required this._dio})
    : _refreshDio = Dio(BaseOptions(baseUrl: Env.baseUrl));

  final TokenStorage _tokenStorage;
  final Dio _dio; // main client — used to retry the failed request
  final Dio _refreshDio; // bare client for the refresh call (no interceptors)

  Future<String?>? _refreshFuture;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Public endpoints (login/register/refresh/logout) get no token.
    if (ApiEndpoints.isPublicPost(options.method, options.path)) {
      handler.next(options);
      return;
    }

    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers[AppConstants.authorizationHeader] =
          '${AppConstants.bearerPrefix}$token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final isRetry = options.extra['isRetry'] == true;
    final isPublic = ApiEndpoints.isPublicPost(options.method, options.path);

    if (err.response?.statusCode == 401 && !isRetry && !isPublic) {
      try {
        final newToken = await _refresh();
        if (newToken != null && newToken.isNotEmpty) {
          options.headers[AppConstants.authorizationHeader] =
              '${AppConstants.bearerPrefix}$newToken';
          options.extra['isRetry'] = true; // never refresh more than once
          final response = await _dio.fetch(options);
          handler.resolve(response);
          return;
        }
      } on DioException {
        // refresh failed → fall through and surface the original 401
      }
    }
    handler.next(err);
  }

  /// Deduplicates concurrent refreshes into a single network call.
  Future<String?> _refresh() {
    _refreshFuture ??= _doRefresh().whenComplete(() => _refreshFuture = null);
    return _refreshFuture!;
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final res = await _refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      final envelope = res.data as Map<String, dynamic>;
      final login = LoginResponse.fromJson(
        envelope['data'] as Map<String, dynamic>,
      );

      await _tokenStorage.saveTokens(
        accessToken: login.token ?? '',
        refreshToken: login.refreshToken ?? '',
        tokenType: login.tokenType,
        expiresIn: login.expiresIn,
        refreshExpiresIn: login.refreshExpiresIn,
        roles: login.roles,
      );
      return login.token;
    } on DioException {
      return null;
    }
  }
}
