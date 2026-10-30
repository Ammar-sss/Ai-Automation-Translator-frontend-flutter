import 'package:drift/drift.dart';
import 'package:smart_translator/core/database/app_database.dart';
import '../../../translation/data/models/ai_response.dart';

abstract interface class VocabularyLocalDataSource {
  Future<int> saveTermLocally(AiResponse r, int userId);
  Future<List<LocalTerm>> getAllLocalTerms();
  Future<LocalTerm?> getLocalTermById(int id);
  Stream<List<LocalTerm>> watchLocalTerms();
}

class VocabularyLocalDataSourceImpl implements VocabularyLocalDataSource {
  const VocabularyLocalDataSourceImpl(this._db);
  final AppDatabase _db;

  @override
  Future<int> saveTermLocally(AiResponse r, int userId) async {
    final word = r.termWord?.trim();
    if (word == null || word.isEmpty) {
      throw ArgumentError('termWord is required');
    }

    return _db.transaction(() async {
      final termId = await _db
          .into(_db.terms)
          .insert(TermsCompanion.insert(userId: userId, word: word));

      await _db.batch((b) {
        b.insertAll(_db.termDefinitions, [
          for (final d in r.termDefinitions ?? const <String>{})
            TermDefinitionsCompanion.insert(termId: termId, definition: d),
        ]);
      });

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

  @override
  Future<List<LocalTerm>> getAllLocalTerms() {
    return _db.select(_db.terms).get();
  }

  @override
  Future<LocalTerm?> getLocalTermById(int id) {
    return (_db.select(_db.terms)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  @override
  Stream<List<LocalTerm>> watchLocalTerms() {
    return (_db.select(_db.terms)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}
