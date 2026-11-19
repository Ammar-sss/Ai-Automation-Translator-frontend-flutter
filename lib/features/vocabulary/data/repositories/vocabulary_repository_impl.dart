import 'package:smart_translator_test/core/error/app_exception.dart';
import 'package:smart_translator_test/core/util/api_response.dart';
import 'package:smart_translator_test/features/translate/data/models/ai_response.dart';
import 'package:smart_translator_test/features/vocabulary/data/datasource/vocabulary_remote_datasource.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/domain/repositories/vocabulary_repository.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final VocabularyRemoteDatasource _vocabularyRemoteDatasource;

  new({required this._vocabularyRemoteDatasource});

  @override
  Future<ApiResponse<Term>> confirmTermSave(AiResponse aiResponse) async {
    try {
      return await _vocabularyRemoteDatasource.confirmTermSave(aiResponse);
    } catch (e) {
      throw ApiErrorHandler.handle(
        e,
        fallback: 'Failed to save the term. Please try again.',
      );
    }
  }

  @override
  Future<ApiResponse<void>> deleteTermById(int id) async {
    try {
      return await _vocabularyRemoteDatasource.deleteTermById(id);
    } catch (e) {
      throw ApiErrorHandler.handle(
        e,
        fallback: 'Failed to delete the term. Please try again.',
      );
    }
  }

  @override
  Future<ApiResponse<List<Term>>> getAllTerms() async {
    try {
      return await _vocabularyRemoteDatasource.getAllTerms();
    } catch (e) {
      throw ApiErrorHandler.handle(
        e,
        fallback: 'Failed to retrieve all terms. Please try again.',
      );
    }
  }

  @override
  Future<ApiResponse<Term>> getTermById(int id) async {
    try {
      return await _vocabularyRemoteDatasource.getTermById(id);
    } catch (e) {
      throw ApiErrorHandler.handle(
        e,
        fallback: 'Failed to retrieve term by id. Please try again.',
      );
    }
  }
}
