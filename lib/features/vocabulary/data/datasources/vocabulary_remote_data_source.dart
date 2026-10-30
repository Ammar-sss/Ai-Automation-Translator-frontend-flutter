import 'package:dio/dio.dart';
import 'package:smart_translator/core/config/api_endpoints.dart';
import 'package:smart_translator/core/errors/api_exception.dart';
import '../../../translation/data/models/ai_response.dart';
import '../models/term.dart';

abstract interface class VocabularyRemoteDataSource {
  Future<void> confirmTermSave(AiResponse aiResponse);
  Future<List<Term>> getAllTerms();
  Future<Term> getTermByID(int id);
}

class VocabularyRemoteDataSourceImpl implements VocabularyRemoteDataSource {
  const VocabularyRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<void> confirmTermSave(AiResponse aiResponse) async {
    try {
      await _dio.post(
        ApiEndpoints.addTerm,
        data: AiResponse(
          termWord: aiResponse.termWord,
          exampleSentence: aiResponse.exampleSentence,
          termDefinitions: aiResponse.termDefinitions,
          exampleDefinition: aiResponse.exampleDefinition,
        ).toJson(),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<Term>> getAllTerms() async {
    try {
      final res = await _dio.get(ApiEndpoints.getAllTerm);
      final envelope = res.data as Map<String, dynamic>;
      final list = envelope['data'] as List<dynamic>;
      return list.map((e) => Term.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Term> getTermByID(int id) async {
    try {
      final res = await _dio.get(ApiEndpoints.getTermByID(id));
      final envelope = res.data as Map<String, dynamic>;
      return Term.fromJson(envelope['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
