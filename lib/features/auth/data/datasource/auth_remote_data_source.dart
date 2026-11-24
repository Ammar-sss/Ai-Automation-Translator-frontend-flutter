import 'package:smart_translator_test/core/error/app_exception.dart';
import 'package:smart_translator_test/features/auth/data/datasource/auth_api_service.dart';

import '../../../user/data/models/user.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/refresh_token_request.dart';
import '../models/register_request.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest loginRequest);
  Future<void> logout(RefreshTokenRequest request);
  Future<LoginResponse> refreshToken(RefreshTokenRequest request);
  Future<User> register(RegisterRequest registerRequest);
}

class AuthRemoteDataSourceImpl extends AuthRemoteDataSource {
  final AuthApiService _apiService;

  AuthRemoteDataSourceImpl({required this._apiService});

  @override
  Future<LoginResponse> login(LoginRequest loginRequest) async {
    final apiResponse = await _apiService.login(loginRequest);
    if (apiResponse.data == null) {
      throw AppException(
        apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Login failed: no data returned',
      );
    }
    return apiResponse.data!;
  }

  @override
  Future<void> logout(RefreshTokenRequest request) async {
    await _apiService.logout(request);
  }

  @override
  Future<LoginResponse> refreshToken(RefreshTokenRequest request) async {
    final apiResponse = await _apiService.refreshToken(request);
    if (apiResponse.data == null) {
      throw AppException(
        apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Token refresh failed: no data returned',
      );
    }
    return apiResponse.data!;
  }

  @override
  Future<User> register(RegisterRequest registerRequest) async {
    final apiResponse = await _apiService.register(registerRequest);
    if (apiResponse.data == null) {
      throw AppException(
        apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Registration failed: no user data returned',
      );
    }
    return apiResponse.data!;
  }
}
