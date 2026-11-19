import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:smart_translator_test/core/network/api_endpoint.dart';
import 'package:smart_translator_test/core/util/api_response.dart';
import 'package:smart_translator_test/features/translate/data/models/ai_response.dart';
import 'package:smart_translator_test/features/translate/data/models/translate_request.dart';

part 'translate_remote_data_source.g.dart';

@RestApi()
abstract class TranslateRemoteDataSource {
  factory TranslateRemoteDataSource(Dio dio, {String baseUrl}) =
      _TranslateRemoteDataSource;

  @POST(ApiEndpoint.translate)
  Future<ApiResponse<AiResponse>> translate(
    @Body() TranslateRequest translateRequest,
  );
}
