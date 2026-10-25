import 'package:dio/dio.dart';
import 'package:smart_translator/core/errors/api_exception.dart';
import 'package:smart_translator/core/models/user.dart';
import 'package:smart_translator/features/auth/data/models/login_response.dart';

import '../../../../core/config/api_endpoints.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  Future<LoginResponse> login(String email, String password) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.login,
        data: LoginRequest(email: email, password: password).toJson(),
      );
      final env = res.data as Map<String, dynamic>;
      return LoginResponse.fromJson(env['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<User> register(String username, String email, String password) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.register,
        data: RegisterRequest(
          username: username,
          email: email,
          password: password,
        ).toJson(),
      );
      final env = res.data as Map<String, dynamic>;
      return User.fromJson(env['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(
        ApiEndpoints.logout,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
