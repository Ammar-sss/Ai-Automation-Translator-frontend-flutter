import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:smart_translator/core/database/app_database.dart';
import '../../../../core/config/api_endpoints.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../translation/data/models/ai_response.dart';
import '../models/term.dart';

class VocabularyRepository {
  VocabularyRepository(this._dio, this._db);

  final Dio _dio;
  final AppDatabase _db;

  /// Saves a term to the remote API.
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

  /// Saves a term locally using Drift (offline-first).
  /// Returns the new term's ID.
  Future<int> saveTermLocally(AiResponse r, int userId) async {
    final word = r.termWord?.trim();
    if (word == null || word.isEmpty) {
      throw ArgumentError('termWord is required');
    }

    return _db.transaction(() async {
      // Insert parent term
      final termId = await _db
          .into(_db.terms)
          .insert(TermsCompanion.insert(userId: userId, word: word));

      // Insert definitions in batch
      await _db.batch((b) {
        b.insertAll(_db.termDefinitions, [
          for (final d in r.termDefinitions ?? const <String>{})
            TermDefinitionsCompanion.insert(termId: termId, definition: d),
        ]);
      });

      // Insert example + its definition
      final sentence = r.exampleSentence;
      if (sentence != null) {
        await _db
            .into(_db.examples)
            .insert(
              ExamplesCompanion.insert(
                termId: termId,
                sentence: sentence,
                definition: Value(r.exampleDefinition),
              ),
            );
      }
      return termId;
    });
  }

  /// Remote API: fetch all terms
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

  /// Remote API: fetch single term
  Future<Term> getTermByID(int id) async {
    try {
      final res = await dbGetTermByID(id);
      final envelope = res.data as Map<String, dynamic>;
      return Term.fromJson(envelope['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Response<dynamic>> dbGetTermByID(int id) async {
    return await _dio.get(ApiEndpoints.getTermByID(id));
  }

  // ===== LOCAL DATABASE METHODS (Drift) =====

  /// Get all terms from LOCAL database as Drift entities
  Future<List<LocalTerm>> getAllLocalTerms() async {
    return await (_db.select(_db.terms).get());
  }

  /// Get single term by ID from LOCAL database
  Future<LocalTerm?> getLocalTermById(int id) async {
    return await (_db.select(
      _db.terms,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Reactive stream: emits whenever terms change
  Stream<List<LocalTerm>> watchLocalTerms() => (_db.select(
    _db.terms,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
}
