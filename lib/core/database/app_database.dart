import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('LocalTerm')
class Terms extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer().nullable()();
  IntColumn get userId => integer()();
  TextColumn get word => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, word},
  ];
}

@TableIndex(name: 'idx_definitions_term', columns: {#termId})
class TermDefinitions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get termId =>
      integer().references(Terms, #id, onDelete: KeyAction.cascade)();
  TextColumn get definition => text()();
}

@TableIndex(name: 'idx_examples_term', columns: {#termId})
class Examples extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get termId =>
      integer().references(Terms, #id, onDelete: KeyAction.cascade)();
  TextColumn get sentence => text()();
  TextColumn get definition => text().nullable()();
}

@DriftDatabase(tables: [Terms, TermDefinitions, Examples])
class AppDatabase extends _$AppDatabase {
  // Injectable executor => you can use NativeDatabase.memory() in tests
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'smart_translator'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
    // add onUpgrade with stepByStep(...) from your first schema change
  );
}
