import '../../../user/data/models/user.dart';
import '../../data/models/login_request.dart';
import '../../data/models/login_response.dart';
import '../../data/models/refresh_token_request.dart';
import '../../data/models/register_request.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest loginRequest);
  Future<User> register(RegisterRequest registerRequest);
  Future<LoginResponse> refreshToken(RefreshTokenRequest request);
  Future<void> logout(RefreshTokenRequest request);
}