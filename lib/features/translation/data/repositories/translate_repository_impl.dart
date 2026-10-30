import 'package:dio/dio.dart';
import 'package:smart_translator/core/models/language_target.dart';
import 'package:smart_translator/features/translation/data/datasources/translate_remote_data_source.dart';
import 'package:smart_translator/features/translation/data/models/ai_response.dart';
import 'package:smart_translator/features/translation/domain/repositories/translate_repository.dart';

class TranslateRepositoryImpl implements TranslateRepository {
  const TranslateRepositoryImpl(this._remoteDataSource);

  factory TranslateRepositoryImpl.fromDio(Dio dio) {
    return TranslateRepositoryImpl(
      TranslateRemoteDataSourceImpl(dio),
    );
  }

  final TranslateRemoteDataSource _remoteDataSource;

  @override
  Future<AiResponse> translate(
    String termWord,
    LanguageTarget sourceLanguage,
    LanguageTarget targetLanguage,
  ) {
    return _remoteDataSource.translate(
      termWord,
      sourceLanguage,
      targetLanguage,
    );
  }
}
