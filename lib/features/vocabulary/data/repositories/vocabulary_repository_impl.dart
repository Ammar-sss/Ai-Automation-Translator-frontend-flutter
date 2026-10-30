import 'package:dio/dio.dart';
import 'package:smart_translator/core/database/app_database.dart';
import 'package:smart_translator/features/translation/data/models/ai_response.dart';
import 'package:smart_translator/features/vocabulary/data/datasources/vocabulary_local_data_source.dart';
import 'package:smart_translator/features/vocabulary/data/datasources/vocabulary_remote_data_source.dart';
import 'package:smart_translator/features/vocabulary/data/models/term.dart';
import 'package:smart_translator/features/vocabulary/domain/repositories/vocabulary_repository.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  const VocabularyRepositoryImpl(this._remoteDataSource, this._localDataSource);

  factory VocabularyRepositoryImpl.create(Dio dio, AppDatabase db) {
    return VocabularyRepositoryImpl(
      VocabularyRemoteDataSourceImpl(dio),
      VocabularyLocalDataSourceImpl(db),
    );
  }

  final VocabularyRemoteDataSource _remoteDataSource;
  final VocabularyLocalDataSource _localDataSource;

  @override
  Future<void> confirmTermSave(AiResponse aiResponse) {
    return _remoteDataSource.confirmTermSave(aiResponse);
  }

  @override
  Future<int> saveTermLocally(AiResponse r, int userId) {
    return _localDataSource.saveTermLocally(r, userId);
  }

  @override
  Future<List<Term>> getAllTerms() {
    return _remoteDataSource.getAllTerms();
  }

  @override
  Future<Term> getTermByID(int id) {
    return _remoteDataSource.getTermByID(id);
  }

  @override
  Future<List<LocalTerm>> getAllLocalTerms() {
    return _localDataSource.getAllLocalTerms();
  }

  @override
  Future<LocalTerm?> getLocalTermById(int id) {
    return _localDataSource.getLocalTermById(id);
  }

  @override
  Stream<List<LocalTerm>> watchLocalTerms() {
    return _localDataSource.watchLocalTerms();
  }
}
