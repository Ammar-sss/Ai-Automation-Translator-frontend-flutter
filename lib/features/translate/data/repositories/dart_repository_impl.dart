import 'package:smart_translator_test/core/error/app_exception.dart';
import 'package:smart_translator_test/core/util/api_response.dart';
import 'package:smart_translator_test/features/translate/data/datasource/translate_remote_data_source.dart';
import 'package:smart_translator_test/features/translate/data/models/ai_response.dart';
import 'package:smart_translator_test/features/translate/data/models/translate_request.dart';
import 'package:smart_translator_test/features/translate/domain/repositories/translate_repository.dart';

class TranslateRepositoryImpl implements TranslateRepository {
  final TranslateRemoteDataSource _translateRemoteDataSource;

  TranslateRepositoryImpl({required this._translateRemoteDataSource});

  @override
  Future<ApiResponse<AiResponse>> translate(TranslateRequest translateRequest) async {
    try {
      return await _translateRemoteDataSource.translate(translateRequest);
    } catch (e) {
      throw ApiErrorHandler.handle(e, fallback: 'Translation failed. Please try again.');
    }
  }
}
