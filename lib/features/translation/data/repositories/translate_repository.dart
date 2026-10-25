import 'package:dio/dio.dart';
import 'package:smart_translator/core/config/api_endpoints.dart';
import 'package:smart_translator/core/errors/api_exception.dart';
import 'package:smart_translator/features/translation/data/models/ai_response.dart';

import '../models/translate_request.dart';

class TranslateRepository {
  const TranslateRepository(this._dio);
  final Dio _dio;

  Future<AiResponse> translate(String termWord) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.translate,
        data: TranslateRequest(termWord: termWord).toJson(),
      );
      final env = res.data as Map<String, dynamic>;
      return AiResponse.fromJson(env['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
