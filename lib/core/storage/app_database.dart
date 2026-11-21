import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart'
    as models;

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table Definitions
// ---------------------------------------------------------------------------

/// Folders table – each folder has a unique name.
class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Terms table – each term is stored ONCE with its full data as JSON.
/// We name the generated row class `TermRow` to avoid colliding with `models.Term`.
@DataClassName('TermRow')
class Terms extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The word itself, stored in lowercase for uniqueness.
  TextColumn get termWord => text().unique()();

  /// The full AI response data serialized as a JSON string.
  /// Contains definitions, examples, example definitions, etc.
  TextColumn get termData => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Junction table for the Many-to-Many relationship between Terms and Folders.
/// This allows a term like "sister" to exist in both "People" and "Family" folders.
@DataClassName('TermFolderEntry')
class TermFolders extends Table {
  IntColumn get termId => integer().references(Terms, #id)();
  IntColumn get folderId => integer().references(Folders, #id)();

  @override
  Set<Column> get primaryKey => {termId, folderId};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [Folders, Terms, TermFolders])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  AppDatabase._() : super(_openConnection());

  /// Singleton instance
  static final AppDatabase instance = AppDatabase._();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      // Ensure folder_id on junction table is indexed to prevent full table scans
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_term_folders_folder_id ON term_folders (folder_id);',
      );
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'smart_translator');
  }

  // -------------------------------------------------------------------------
  // Folder Operations
  // -------------------------------------------------------------------------

  /// Creates a new folder. Returns the row id.
  Future<int> createFolder(String folderName) {
    return into(folders).insert(
      FoldersCompanion.insert(name: folderName),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Returns all folders ordered by name.
  Future<List<Folder>> getAllFolders() {
    return (select(folders)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  /// Returns all folders with their term count in a SINGLE SQL query.
  /// Eliminates the N+1 query and avoids decoding any JSON blobs for counting.
  Future<List<({Folder folder, int termCount})>>
  getAllFoldersWithTermCount() async {
    final countExp = termFolders.termId.count();
    final query =
        select(folders).join([
            leftOuterJoin(
              termFolders,
              termFolders.folderId.equalsExp(folders.id),
            ),
          ])
          ..groupBy([folders.id, folders.name, folders.createdAt])
          ..orderBy([OrderingTerm.asc(folders.name)])
          ..addColumns([countExp]);

    final rows = await query.get();
    return rows.map((row) {
      final folder = row.readTable(folders);
      final count = row.read(countExp) ?? 0;
      return (folder: folder, termCount: count);
    }).toList();
  }

  /// Renames a folder.
  Future<bool> renameFolder(int folderId, String newName) async {
    final count = await (update(folders)..where((t) => t.id.equals(folderId)))
        .write(FoldersCompanion(name: Value(newName)));
    return count > 0;
  }

  /// Deletes a folder and all its links in the junction table.
  Future<void> deleteFolder(int folderId) async {
    await transaction(() async {
      // Remove all links first
      await (delete(
        termFolders,
      )..where((t) => t.folderId.equals(folderId))).go();
      // Then remove the folder
      await (delete(folders)..where((t) => t.id.equals(folderId))).go();
    });
  }

  // -------------------------------------------------------------------------
  // Term Operations
  // -------------------------------------------------------------------------

  /// Saves a [models.Term] into a specific folder.
  ///
  /// - If the term already exists (by `termWord`), it reuses the existing row.
  /// - Then links the term to the folder via the junction table.
  ///
  /// Example: saving "sister" to folder "People" (id=1) and "Family" (id=2)
  /// results in ONE row in `terms` and TWO rows in `term_folders`.
  Future<void> saveTermToFolder({
    required models.Term term,
    required int folderId,
  }) async {
    await transaction(() async {
      final cleanWord = term.termWord.trim().toLowerCase();

      // 1. Try to find existing term
      final existing = await (select(
        terms,
      )..where((t) => t.termWord.equals(cleanWord))).getSingleOrNull();

      int termId;
      if (existing != null) {
        termId = existing.id;
        // If the new term has an ID (>0), persist the updated data into SQLite.
        if (term.id > 0) {
          await (update(terms)..where((t) => t.id.equals(termId))).write(
            TermsCompanion(termData: Value(jsonEncode(term.toJson()))),
          );
        }
      } else {
        // Insert new term
        termId = await into(terms).insert(
          TermsCompanion.insert(
            termWord: cleanWord,
            termData: jsonEncode(term.toJson()),
          ),
        );
      }

      // 2. Link term to folder (ignore if already linked)
      await into(termFolders).insert(
        TermFoldersCompanion.insert(termId: termId, folderId: folderId),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  /// Gets all [models.Term]s belonging to a specific folder.
  Future<List<models.Term>> getTermsByFolderId(int folderId) async {
    final query = select(terms).join([
      innerJoin(termFolders, termFolders.termId.equalsExp(terms.id)),
    ])..where(termFolders.folderId.equals(folderId));

    final rows = await query.get();

    return rows.map((row) {
      final termRow = row.readTable(terms);
      final jsonMap = jsonDecode(termRow.termData) as Map<String, dynamic>;
      return models.Term.fromJson(jsonMap);
    }).toList();
  }

  /// Gets all folder IDs linked to a specific term word.
  /// e.g. "sister" → [1, 2]
  Future<List<int>> getFolderIdsForTerm(String termWord) async {
    final query = select(termFolders).join([
      innerJoin(terms, terms.id.equalsExp(termFolders.termId)),
    ])..where(terms.termWord.equals(termWord.toLowerCase()));

    final rows = await query.get();
    return rows.map((row) => row.readTable(termFolders).folderId).toList();
  }

  /// Checks if a term word already exists in the local database.
  Future<models.Term?> getExistingTerm(String termWord) async {
    final lowerWord = termWord.trim().toLowerCase();
    final existing = await (select(
      terms,
    )..where((t) => t.termWord.equals(lowerWord))).getSingleOrNull();

    if (existing == null) return null;
    final jsonMap = jsonDecode(existing.termData) as Map<String, dynamic>;
    return models.Term.fromJson(jsonMap);
  }

  /// Checks if a term word is already linked to a specific folder.
  Future<bool> isTermInFolder({
    required String termWord,
    required int folderId,
  }) async {
    final folderIds = await getFolderIdsForTerm(termWord);
    return folderIds.contains(folderId);
  }

  /// Gets all folders that a specific term belongs to.
  Future<List<Folder>> getFoldersForTerm(String termWord) async {
    final query = select(folders).join([
      innerJoin(termFolders, termFolders.folderId.equalsExp(folders.id)),
      innerJoin(terms, terms.id.equalsExp(termFolders.termId)),
    ])..where(terms.termWord.equals(termWord.toLowerCase()));

    final rows = await query.get();
    return rows.map((row) => row.readTable(folders)).toList();
  }

  /// Updates the stored [models.Term] data in the local database.
  /// Used when a locally saved term is successfully synced with the cloud.
  Future<void> updateTerm(models.Term term) async {
    final cleanWord = term.termWord.trim().toLowerCase();
    await (update(terms)..where((t) => t.termWord.equals(cleanWord))).write(
      TermsCompanion(termData: Value(jsonEncode(term.toJson()))),
    );
  }

  /// Removes a term from a specific folder (but keeps the term in the DB).
  /// If the term has no more folders, it is deleted entirely.
  Future<void> removeTermFromFolder({
    required int termId,
    required int folderId,
    String? termWord,
  }) async {
    await transaction(() async {
      int effectiveTermId = termId;
      if (termWord != null && termWord.isNotEmpty) {
        final row =
            await (select(terms)..where(
                  (t) => t.termWord.equals(termWord.trim().toLowerCase()),
                ))
                .getSingleOrNull();
        if (row != null) {
          effectiveTermId = row.id;
        }
      }

      // Remove the link
      await (delete(termFolders)..where(
            (t) =>
                t.termId.equals(effectiveTermId) & t.folderId.equals(folderId),
          ))
          .go();

      // Check if the term still belongs to any folder
      final remaining = await (select(
        termFolders,
      )..where((t) => t.termId.equals(effectiveTermId))).get();

      // If orphaned, delete the term entirely
      if (remaining.isEmpty) {
        await (delete(terms)..where((t) => t.id.equals(effectiveTermId))).go();
      }
    });
  }

  /// Deletes a term completely from all folders and the terms table.
  Future<void> deleteTermCompletely(int termId) async {
    await transaction(() async {
      await (delete(termFolders)..where((t) => t.termId.equals(termId))).go();
      await (delete(terms)..where((t) => t.id.equals(termId))).go();
    });
  }

  /// Resets a term's cloud sync ID to 0 when deleted from synced vocabulary,
  /// keeping it in local folders as an unsaved/local term.
  Future<void> resetTermCloudStatus(int termId) async {
    final allRows = await select(terms).get();
    for (final row in allRows) {
      try {
        final jsonMap = jsonDecode(row.termData) as Map<String, dynamic>;
        final jsonId = (jsonMap['id'] as num?)?.toInt() ?? 0;
        if (jsonId == termId) {
          jsonMap['id'] = 0;
          final updatedJson = jsonEncode(jsonMap);
          await (update(terms)..where((t) => t.id.equals(row.id))).write(
            TermsCompanion(termData: Value(updatedJson)),
          );
        }
      } catch (_) {}
    }
  }

  /// Searches for terms by keyword (partial match).
  Future<List<models.Term>> searchTerms(String keyword) async {
    final query = select(terms)
      ..where((t) => t.termWord.like('%${keyword.toLowerCase()}%'));

    final rows = await query.get();
    return rows.map((row) {
      final jsonMap = jsonDecode(row.termData) as Map<String, dynamic>;
      return models.Term.fromJson(jsonMap);
    }).toList();
  }

  /// Gets all saved terms (regardless of folder).
  Future<List<models.Term>> getAllTerms() async {
    final rows = await select(terms).get();
    return rows.map((row) {
      final jsonMap = jsonDecode(row.termData) as Map<String, dynamic>;
      return models.Term.fromJson(jsonMap);
    }).toList();
  }

  /// Returns the most recently saved terms, limited to [limit].
  /// Directly limits and sorts in SQLite so only [limit] JSON blobs are decoded.
  Future<List<models.Term>> getRecentTerms({int limit = 5}) async {
    final query = select(terms)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      final jsonMap = jsonDecode(row.termData) as Map<String, dynamic>;
      return models.Term.fromJson(jsonMap);
    }).toList();
  }

  /// Returns total count of saved terms directly via SQLite COUNT(*).
  /// Fast O(1) query without loading or decoding any JSON blobs.
  Future<int> getTermsCount() async {
    final countExp = terms.id.count();
    final query = selectOnly(terms)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Returns the word of the day using a stable index based on day of month.
  /// Queries only a single row directly from SQLite without loading all terms.
  Future<models.Term?> getWordOfTheDay() async {
    final count = await getTermsCount();
    if (count == 0) return null;
    final dayOffset = DateTime.now().day % count;
    final query = select(terms)..limit(1, offset: dayOffset);
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final jsonMap = jsonDecode(row.termData) as Map<String, dynamic>;
    return models.Term.fromJson(jsonMap);
  }

  /// Watches all terms in a folder reactively (stream).
  Stream<List<models.Term>> watchTermsByFolderId(int folderId) {
    final query = select(terms).join([
      innerJoin(termFolders, termFolders.termId.equalsExp(terms.id)),
    ])..where(termFolders.folderId.equals(folderId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final termRow = row.readTable(terms);
        final jsonMap = jsonDecode(termRow.termData) as Map<String, dynamic>;
        return models.Term.fromJson(jsonMap);
      }).toList();
    });
  }

  /// Watches all folders reactively (stream).
  Stream<List<Folder>> watchAllFolders() {
    return (select(
      folders,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }
}
