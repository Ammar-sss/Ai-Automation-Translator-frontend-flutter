import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:smart_translator_test/core/network/api_endpoint.dart';
import 'package:smart_translator_test/core/util/api_response.dart';
import 'package:smart_translator_test/features/auth/data/models/login_request.dart';
import 'package:smart_translator_test/features/auth/data/models/login_response.dart';
import 'package:smart_translator_test/features/auth/data/models/refresh_token_request.dart';
import 'package:smart_translator_test/features/auth/data/models/register_request.dart';
import 'package:smart_translator_test/features/user/data/models/user.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST(ApiEndpoint.login)
  Future<ApiResponse<LoginResponse>> login(@Body() LoginRequest loginRequest);

  @POST(ApiEndpoint.register)
  Future<ApiResponse<User>> register(@Body() RegisterRequest registerRequest);

  @POST(ApiEndpoint.refresh)
  Future<ApiResponse<LoginResponse>> refreshToken(
    @Body() RefreshTokenRequest request,
  );

  @POST(ApiEndpoint.logout)
  Future<ApiResponse<void>> logout(@Body() RefreshTokenRequest request);
}
