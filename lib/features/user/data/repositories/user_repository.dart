// TODO: Practice building user_repository.dart
import 'package:dio/dio.dart';
import 'package:smart_translator/core/config/api_endpoints.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/models/user.dart';

class UserRepository {
  UserRepository(this._dio);
  final Dio _dio;

  Future<User> getProfile() async {
    try {
      final red = await _dio.get(ApiEndpoints.me);
      final env = red.data as Map<String, dynamic>;
      return User.fromJson(env['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<User> updateProfile(User user) async {
    try {
      final res = await _dio.put(ApiEndpoints.me, data: user.toJson());
      final env = res.data as Map<String, dynamic>;
      return User.fromJson(env['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
