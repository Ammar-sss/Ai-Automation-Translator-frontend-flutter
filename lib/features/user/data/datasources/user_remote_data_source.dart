import 'package:dio/dio.dart';
import 'package:smart_translator/core/config/api_endpoints.dart';
import 'package:smart_translator/core/errors/api_exception.dart';
import 'package:smart_translator/core/models/user.dart';

abstract interface class UserRemoteDataSource {
  Future<User> getProfile();
  Future<User> updateProfile(User user);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  const UserRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<User> getProfile() async {
    try {
      final res = await _dio.get(ApiEndpoints.me);
      final env = res.data as Map<String, dynamic>;
      return User.fromJson(env['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
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
