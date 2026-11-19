import 'package:smart_translator_test/core/error/app_exception.dart';
import 'package:smart_translator_test/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:smart_translator_test/features/auth/data/models/login_request.dart';
import 'package:smart_translator_test/features/auth/data/models/login_response.dart';
import 'package:smart_translator_test/features/auth/data/models/refresh_token_request.dart';
import 'package:smart_translator_test/features/auth/data/models/register_request.dart';
import 'package:smart_translator_test/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_translator_test/features/user/data/models/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  new({required this.authRemoteDataSource});

  @override
  Future<LoginResponse> login(LoginRequest loginRequest) async {
    try {
      return await authRemoteDataSource.login(loginRequest);
    } catch (e) {
      throw ApiErrorHandler.handle(
        e,
        fallback: 'Login failed. Please check your credentials.',
      );
    }
  }

  @override
  Future<User> register(RegisterRequest registerRequest) async {
    try {
      return await authRemoteDataSource.register(registerRequest);
    } catch (e) {
      throw ApiErrorHandler.handle(
        e,
        fallback: 'Registration failed. Please try again.',
      );
    }
  }

  @override
  Future<LoginResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      return await authRemoteDataSource.refreshToken(request);
    } catch (e) {
      throw ApiErrorHandler.handle(
        e,
        fallback: 'Session expired. Please log in again.',
      );
    }
  }

  @override
  Future<void> logout(RefreshTokenRequest request) async {
    try {
      await authRemoteDataSource.logout(request);
    } catch (e) {
      throw ApiErrorHandler.handle(e, fallback: 'Logout failed.');
    }
  }
}
