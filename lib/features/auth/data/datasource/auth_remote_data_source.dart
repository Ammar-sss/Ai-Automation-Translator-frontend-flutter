import 'package:smart_translator_test/core/storage/secure_storage_service.dart';
import 'package:smart_translator_test/features/auth/data/datasource/auth_api_service.dart';

import '../../../user/data/models/user.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/refresh_token_request.dart';
import '../models/register_request.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest loginRequest);
  Future<User> register(RegisterRequest registerRequest);
  Future<LoginResponse> refreshToken(RefreshTokenRequest request);
  Future<void> logout(RefreshTokenRequest request);
}

class AuthRemoteDataSourceImpl extends AuthRemoteDataSource {
  final AuthApiService _apiService;
  final SecureStorageService _storageService;

  new({required this._apiService, required this._storageService});

  @override
  Future<LoginResponse> login(LoginRequest loginRequest) async {
    final apiResponse = await _apiService.login(loginRequest);
    final loginResponse = apiResponse.data!;
    await _storageService.saveToken(
      loginResponse.token,
      loginResponse.refreshToken,
    );
    return loginResponse;
  }

  @override
  Future<void> logout(RefreshTokenRequest request) async {
    await _apiService.logout(request);
    await _storageService.clearToken();
  }

  @override
  Future<LoginResponse> refreshToken(RefreshTokenRequest request) async {
    final apiResponse = await _apiService.refreshToken(request);
    final loginResponse = apiResponse.data!;
    await _storageService.saveToken(
      loginResponse.token,
      loginResponse.refreshToken,
    );
    return loginResponse;
  }

  @override
  Future<User> register(RegisterRequest registerRequest) async {
    final apiResponse = await _apiService.register(registerRequest);
    return apiResponse.data!;
  }
}
