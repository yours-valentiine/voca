import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:fsrs/fsrs.dart' show Rating, State;
import 'package:path_provider/path_provider.dart';
import 'package:voca/data/local/daos.dart';
import 'package:voca/data/local/tables.dart';
import 'package:voca/data/local/views.dart';
import 'package:voca/shared/util/utils.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    DictionaryEntity,
    WordEntity,
    TranslateEntity,
    FsrsEntity,
    FsrsHistoryEntity,
  ],
  views: [WordFull, FsrsFull, WordRepeat, WordRepeatFull],
  daos: [
    DictionaryDao,
    WordDao,
    TranslateDao,
    FsrsDao,
    WordFullDao,
    WordRepeatDao,
    WordRepeatFullDao,
  ],
)
class VocaDatabase extends _$VocaDatabase {
  VocaDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: "voca_dictionary",
      native: DriftNativeOptions(
        databaseDirectory: () => getApplicationSupportDirectory(),
      ),
    );
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
    onCreate: (m) async {
      await m.createAll();

      await into(
        dictionaryEntity,
      ).insert(DictionaryEntityCompanion.insert(name: "General"));

      await customStatement("""
      CREATE TRIGGER IF NOT EXISTS not_delete_last
      AFTER DELETE ON dictionary_entity
      BEGIN
        SELECT CASE
          WHEN (SELECT COUNT(*) FROM dictionary_entity) = 0 THEN
            RAISE(ABORT, 'Need one dictionary')
        END;
      END;
      """);
    },
  );
}
