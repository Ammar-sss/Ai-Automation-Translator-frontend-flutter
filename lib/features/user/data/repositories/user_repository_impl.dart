import 'package:dio/dio.dart';
import 'package:smart_translator/core/models/user.dart';
import 'package:smart_translator/features/user/data/datasources/user_remote_data_source.dart';
import 'package:smart_translator/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._remoteDataSource);

  factory UserRepositoryImpl.fromDio(Dio dio) {
    return UserRepositoryImpl(UserRemoteDataSourceImpl(dio));
  }

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<User> getProfile() => _remoteDataSource.getProfile();

  @override
  Future<User> updateProfile(User user) =>
      _remoteDataSource.updateProfile(user);
}
