import 'package:dio/dio.dart';
import 'package:smart_translator/core/config/api_endpoints.dart';
import 'package:smart_translator/core/errors/api_exception.dart';
import 'package:smart_translator/core/models/language_target.dart';
import '../models/ai_response.dart';
import '../models/translate_request.dart';

abstract interface class TranslateRemoteDataSource {
  Future<AiResponse> translate(
    String termWord,
    LanguageTarget sourceLanguage,
    LanguageTarget targetLanguage,
  );
}

class TranslateRemoteDataSourceImpl implements TranslateRemoteDataSource {
  const TranslateRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AiResponse> translate(
    String termWord,
    LanguageTarget sourceLanguage,
    LanguageTarget targetLanguage,
  ) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.translate,
        data: TranslateRequest(
          termWord: termWord,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        ).toJson(),
      );
      final env = res.data as Map<String, dynamic>;
      return AiResponse.fromJson(env['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
