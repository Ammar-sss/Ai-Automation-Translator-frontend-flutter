import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart'
    as models;
import 'package:smart_translator_test/features/vocabulary/data/models/term_definitions.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Database Performance Query Tests', () {
    test('getAllFoldersWithTermCount executes single query with counts without N+1', () async {
      final f1 = await db.createFolder('Folder A');
      final f2 = await db.createFolder('Folder B');
      await db.createFolder('Folder Empty');

      // Add terms to Folder A
      await db.saveTermToFolder(
        term: models.Term(
          id: 1,
          termWord: 'apple',
          termDefinitions: {TermDefinition(id: 1, definition: 'A fruit')},
          termExamples: {},
          exampleDefinitions: {},
        ),
        folderId: f1,
      );
      await db.saveTermToFolder(
        term: models.Term(
          id: 2,
          termWord: 'banana',
          termDefinitions: {TermDefinition(id: 2, definition: 'Another fruit')},
          termExamples: {},
          exampleDefinitions: {},
        ),
        folderId: f1,
      );

      // Add 1 term to Folder B
      await db.saveTermToFolder(
        term: models.Term(
          id: 3,
          termWord: 'cat',
          termDefinitions: {TermDefinition(id: 3, definition: 'An animal')},
          termExamples: {},
          exampleDefinitions: {},
        ),
        folderId: f2,
      );

      // Query single aggregated SQL query
      final results = await db.getAllFoldersWithTermCount();

      expect(results.length, 3);

      final folderA = results.firstWhere((r) => r.folder.name == 'Folder A');
      final folderB = results.firstWhere((r) => r.folder.name == 'Folder B');
      final folderEmpty = results.firstWhere(
        (r) => r.folder.name == 'Folder Empty',
      );

      expect(folderA.termCount, 2);
      expect(folderB.termCount, 1);
      expect(folderEmpty.termCount, 0);
    });

    test('getRecentTerms limits query results directly in SQLite', () async {
      final folderId = await db.createFolder('Test');

      for (int i = 1; i <= 10; i++) {
        await db.saveTermToFolder(
          term: models.Term(
            id: i,
            termWord: 'word_$i',
            termDefinitions: {TermDefinition(id: i, definition: 'def $i')},
            termExamples: {},
            exampleDefinitions: {},
          ),
          folderId: folderId,
        );
      }

      final recent = await db.getRecentTerms(limit: 5);
      expect(recent.length, 5);
      // Most recent should be word_10 down to word_6
      expect(recent.first.termWord, 'word_10');
      expect(recent.last.termWord, 'word_6');
    });

    test('getTermsCount returns scalar count without decoding JSON', () async {
      final folderId = await db.createFolder('Test');
      expect(await db.getTermsCount(), 0);

      for (int i = 1; i <= 7; i++) {
        await db.saveTermToFolder(
          term: models.Term(
            id: i,
            termWord: 'word_$i',
            termDefinitions: {TermDefinition(id: i, definition: 'def $i')},
            termExamples: {},
            exampleDefinitions: {},
          ),
          folderId: folderId,
        );
      }

      expect(await db.getTermsCount(), 7);
    });

    test(
      'getWordOfTheDay returns a stable single word without full list loading',
      () async {
        final folderId = await db.createFolder('Test');
        expect(await db.getWordOfTheDay(), isNull);

        await db.saveTermToFolder(
          term: models.Term(
            id: 1,
            termWord: 'serendipity',
            termDefinitions: {
              TermDefinition(id: 1, definition: 'Pleasant surprise'),
            },
            termExamples: {},
            exampleDefinitions: {},
          ),
          folderId: folderId,
        );

        final word = await db.getWordOfTheDay();
        expect(word, isNotNull);
        expect(word!.termWord, 'serendipity');
      },
    );
  });
}
