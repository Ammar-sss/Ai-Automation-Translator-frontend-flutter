import 'package:smart_translator_test/core/util/api_response.dart';

import '../../data/models/update_user_profile.dart';
import '../../data/models/user.dart';

abstract class UserRepository {
  Future<ApiResponse<User>> getProfile({bool forceRefresh = false});
  Future<ApiResponse<User>> updateProfile(UpdateUserProfile updateUserProfile);
}