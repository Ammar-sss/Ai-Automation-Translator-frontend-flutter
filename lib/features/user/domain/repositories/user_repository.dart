import 'package:smart_translator/core/models/user.dart';

/// Abstract domain contract for User profile operations.
abstract interface class UserRepository {
  Future<User> getProfile();
  Future<User> updateProfile(User user);
}
