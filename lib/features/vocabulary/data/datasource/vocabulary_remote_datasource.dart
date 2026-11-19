import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:smart_translator_test/core/network/api_endpoint.dart';
import 'package:smart_translator_test/core/util/api_response.dart';
import 'package:smart_translator_test/features/translate/data/models/ai_response.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';

part 'vocabulary_remote_datasource.g.dart';

@RestApi()
abstract class VocabularyRemoteDatasource {
  factory VocabularyRemoteDatasource(Dio dio, {String baseUrl}) =
      _VocabularyRemoteDatasource;

  @POST(ApiEndpoint.confirmTermSave)
  Future<ApiResponse<Term>> confirmTermSave(@Body() AiResponse aiResponse);

  @GET(ApiEndpoint.getTermById)
  Future<ApiResponse<Term>> getTermById(@Path("id") int id);

  @GET(ApiEndpoint.getAllTerms)
  Future<ApiResponse<List<Term>>> getAllTerms();

  @DELETE(ApiEndpoint.deleteTermById)
  Future<ApiResponse<void>> deleteTermById(@Path("id") int id);
}
