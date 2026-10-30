import 'package:dio/dio.dart';
import 'package:smart_translator/core/models/user.dart';
import 'package:smart_translator/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:smart_translator/features/auth/data/models/login_response.dart';
import 'package:smart_translator/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  factory AuthRepositoryImpl.fromDio(Dio dio) {
    return AuthRepositoryImpl(AuthRemoteDataSourceImpl(dio));
  }

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<LoginResponse> login(String email, String password) {
    return _remoteDataSource.login(email, password);
  }

  @override
  Future<User> register(String username, String email, String password) {
    return _remoteDataSource.register(username, email, password);
  }

  @override
  Future<void> logout(String refreshToken) {
    return _remoteDataSource.logout(refreshToken);
  }
}
