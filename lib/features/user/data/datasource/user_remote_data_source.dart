import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:smart_translator_test/core/network/api_endpoint.dart';
import 'package:smart_translator_test/core/util/api_response.dart';
import 'package:smart_translator_test/features/user/data/models/update_user_profile.dart';
import 'package:smart_translator_test/features/user/data/models/user.dart';

part 'user_remote_data_source.g.dart';

@RestApi()
abstract class UserRemoteDataSource {
  factory UserRemoteDataSource(Dio dio , {String baseUrl}) = _UserRemoteDataSource;

  @GET(ApiEndpoint.profile)
  Future<ApiResponse<User>> getProfile();

  @PUT(ApiEndpoint.profile)
  Future<ApiResponse<User>> updateProfile(@Body() UpdateUserProfile updateUserProfile);
}