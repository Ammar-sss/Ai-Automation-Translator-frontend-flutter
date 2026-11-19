import 'dart:convert';

import 'package:smart_translator_test/core/error/app_exception.dart';
import 'package:smart_translator_test/core/storage/secure_storage_service.dart';
import 'package:smart_translator_test/core/util/api_response.dart';
import 'package:smart_translator_test/features/user/data/datasource/user_remote_data_source.dart';
import 'package:smart_translator_test/features/user/data/models/update_user_profile.dart';
import 'package:smart_translator_test/features/user/data/models/user.dart';
import 'package:smart_translator_test/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource userRemoteDataSource;
  final SecureStorageService secureStorageService;

  UserRepositoryImpl({
    required this.userRemoteDataSource,
    required this.secureStorageService,
  });

  @override
  Future<ApiResponse<User>> getProfile({bool forceRefresh = false}) async {
    // 1. If forceRefresh is false, try loading from local cache first (No API call!)
    if (!forceRefresh) {
      final cachedJson = await secureStorageService.getUserJson();
      if (cachedJson != null) {
        final userMap = jsonDecode(cachedJson) as Map<String, dynamic>;
        final user = User.fromJson(userMap);
        return ApiResponse(
          statusCode: 200,
          message: 'Loaded from local cache',
          data: user,
        );
      }
    }

    // 2. If no local cache exists or forceRefresh = true, fetch from API
    try {
      final response = await userRemoteDataSource.getProfile();
      if (response.data != null) {
        await secureStorageService.saveUserJson(
          jsonEncode(response.data!.toJson()),
        );
      }
      return response;
    } catch (e) {
      // 3. Fallback to cache if network call fails during forceRefresh
      final cachedJson = await secureStorageService.getUserJson();
      if (cachedJson != null) {
        final userMap = jsonDecode(cachedJson) as Map<String, dynamic>;
        final user = User.fromJson(userMap);
        return ApiResponse(
          statusCode: 200,
          message: 'Loaded from local cache',
          data: user,
        );
      }
      throw ApiErrorHandler.handle(
        e,
        fallback: 'Failed to load profile. Please try again.',
      );
    }
  }

  @override
  Future<ApiResponse<User>> updateProfile(
    UpdateUserProfile updateUserProfile,
  ) async {
    try {
      final response = await userRemoteDataSource.updateProfile(
        updateUserProfile,
      );
      if (response.data != null) {
        // Update local cache on successful profile update
        await secureStorageService.saveUserJson(
          jsonEncode(response.data!.toJson()),
        );
      }
      return response;
    } catch (e) {
      throw ApiErrorHandler.handle(
        e,
        fallback: 'Failed to update profile. Please try again.',
      );
    }
  }
}
