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

  /// Removes a term from a specific folder (but keeps the term in the DB).
  /// If the term has no more folders, it is deleted entirely.
  Future<void> removeTermFromFolder({
    required int termId,
    required int folderId,
  }) async {
    await transaction(() async {
      // Remove the link
      await (delete(termFolders)..where(
            (t) => t.termId.equals(termId) & t.folderId.equals(folderId),
          ))
          .go();

      // Check if the term still belongs to any folder
      final remaining = await (select(
        termFolders,
      )..where((t) => t.termId.equals(termId))).get();

      // If orphaned, delete the term entirely
      if (remaining.isEmpty) {
        await (delete(terms)..where((t) => t.id.equals(termId))).go();
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
