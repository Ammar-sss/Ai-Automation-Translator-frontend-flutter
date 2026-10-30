import 'package:smart_translator/core/models/user.dart';
import '../../data/models/login_response.dart';

/// Abstract domain contract for authentication.
/// Presentation and Domain layers depend on this contract, not on Dio.
abstract interface class AuthRepository {
  Future<LoginResponse> login(String email, String password);
  Future<User> register(String username, String email, String password);
  Future<void> logout(String refreshToken);
}
