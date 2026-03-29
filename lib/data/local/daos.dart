// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// daos.dart
import 'package:drift/drift.dart';
import 'package:fsrs/fsrs.dart' show Rating;
import 'package:voca/data/local/database.dart';
import 'package:voca/data/local/tables.dart';
import 'package:voca/data/local/views.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [DictionaryEntity])
class DictionaryDao extends DatabaseAccessor<VocaDatabase>
    with _$DictionaryDaoMixin {
  DictionaryDao(super.attachedDatabase);

  Future<DictionaryEntityData?> getSingleOrNull() =>
      (select(dictionaryEntity)
            ..orderBy([(d) => OrderingTerm.asc(d.updatedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<DictionaryEntityData?> getSingle(Uint8List id) =>
      (select(dictionaryEntity)
            ..where((d) => d.dictionaryId.equals(id))
            ..limit(1))
          .getSingleOrNull();

  Future<List<DictionaryEntityData>> getAll() => (select(
    dictionaryEntity,
  )..orderBy([(d) => OrderingTerm.asc(d.updatedAt)])).get();

  Stream<List<DictionaryEntityData>> watchAll() => (select(
    dictionaryEntity,
  )..orderBy([(d) => OrderingTerm.asc(d.updatedAt)])).watch();

  Future<DictionaryEntityData> addSingle(DictionaryEntityCompanion data) =>
      into(dictionaryEntity).insertReturning(data, mode: .insertOrReplace);

  Future<void> deleteSingle(Uint8List dictionaryId) => (delete(
    dictionaryEntity,
  )..where((d) => d.dictionaryId.equals(dictionaryId))).go();
}

@DriftAccessor(tables: [WordEntity])
class WordDao extends DatabaseAccessor<VocaDatabase> with _$WordDaoMixin {
  WordDao(super.attachedDatabase);

  Future<List<WordEntityData>> getAll() => select(wordEntity).get();

  Future<WordEntityData> upsertSingle(WordEntityCompanion data) =>
      into(wordEntity).insertReturning(data, mode: .insertOrReplace);

  Future<void> deleteSingle(Uint8List wordId) =>
      (delete(wordEntity)..where((w) => w.wordId.equals(wordId))).go();
}

@DriftAccessor(tables: [TranslateEntity])
class TranslateDao extends DatabaseAccessor<VocaDatabase>
    with _$TranslateDaoMixin {
  TranslateDao(super.attachedDatabase);

  Future<List<TranslateEntityData>> getAll() => select(translateEntity).get();

  Future<List<TranslateEntityData>> getByWordId(Uint8List wordId) =>
      (select(translateEntity)..where((t) => t.wordId.equals(wordId))).get();

  Future<void> upsertSingle(TranslateEntityCompanion data) =>
      into(translateEntity).insertOnConflictUpdate(data);

  Future<void> addBatch(Iterable<TranslateEntityCompanion> newTranslates) =>
      batch((batch) {
        batch.insertAllOnConflictUpdate(translateEntity, newTranslates);
      });

  Future<void> deleteBatch(Iterable<Uint8List> ids) => batch((b) {
    b.deleteWhere(translateEntity, (t) => t.translateId.isIn(ids));
  });

  Future<void> deleteSingle(Uint8List id) =>
      (delete(translateEntity)..where((t) => t.translateId.equals(id))).go();
}

@DriftAccessor(tables: [FsrsEntity, FsrsHistoryEntity])
class FsrsDao extends DatabaseAccessor<VocaDatabase> with _$FsrsDaoMixin {
  FsrsDao(super.attachedDatabase);

  Future<List<FsrsEntityData>> getAll() => select(fsrsEntity).get();

  Future<void> addSingle(
    FsrsEntityCompanion newFsrs, {
    required Rating rating,
  }) => batch((b) {
    b.insert(fsrsEntity, newFsrs, mode: .insertOrReplace);
    b.insert(
      fsrsHistoryEntity,
      FsrsHistoryEntityCompanion.insert(
        timestampReview: DateTime.timestamp(),
        wordId: newFsrs.wordId.value,
        state: newFsrs.state.value,
        raiting: rating,
      ),
    );
  });
}

@DriftAccessor(views: [WordFull])
class WordFullDao extends DatabaseAccessor<VocaDatabase>
    with _$WordFullDaoMixin {
  WordFullDao(super.attachedDatabase);

  Stream<List<WordFullData>> watchSingle(Uint8List wordId) =>
      (select(wordFull)..where((w) => w.wordId.equals(wordId))).watch();

  Future<List<WordFullData>> getSingle(Uint8List wordId) =>
      (select(wordFull)
            ..where((w) => w.wordId.equals(wordId))
            ..orderBy([(wfd) => OrderingTerm.asc(wfd.position)]))
          .get();

  Stream<List<WordFullData>> watchForDictionary(Uint8List dictionaryId) =>
      (select(wordFull)
            ..where((w) => w.dictionaryId.equals(dictionaryId))
            ..orderBy([
              (wfd) => OrderingTerm.asc(wfd.word),
              (wfd) => OrderingTerm.asc(wfd.position),
            ]))
          .watch();
}

@DriftAccessor(views: [WordRepeat])
class WordRepeatDao extends DatabaseAccessor<VocaDatabase>
    with _$WordRepeatDaoMixin {
  WordRepeatDao(super.attachedDatabase);

  SimpleSelectStatement<$WordRepeatView, WordRepeatData> _selectToday(
    Uint8List dictionaryId,
  ) => select(wordRepeat, distinct: true)
    ..where(
      (w) =>
          w.dictionaryId.equals(dictionaryId) &
          (w.due.isNull() | w.due.isSmallerOrEqualValue(DateTime.timestamp())),
    );

  Stream<int> watchTodayCount(Uint8List dictionaryId) =>
      _selectToday(dictionaryId).watch().map((row) => row.length);

  Stream<int> watchNewCount(Uint8List dictionaryId) =>
      (select(wordRepeat, distinct: true)..where(
            (w) => w.state.isNull() & w.dictionaryId.equals(dictionaryId),
          ))
          .watch()
          .map((w) => w.length);

  Stream<List<WordRepeatData>> watchToday(Uint8List dictionaryId) =>
      _selectToday(dictionaryId).watch();
}

@DriftAccessor(views: [WordRepeatFull])
class WordRepeatFullDao extends DatabaseAccessor<VocaDatabase>
    with _$WordRepeatFullDaoMixin {
  WordRepeatFullDao(super.attachedDatabase);

  SimpleSelectStatement<$WordRepeatFullView, WordRepeatFullData>
  _selectToday() => select(wordRepeatFull)
    ..where(
      (w) => w.due.isNull() | w.due.isSmallerOrEqualValue(DateTime.timestamp()),
    );

  Future<List<WordRepeatFullData>> getTodayForDictionary(
    Uint8List dictionaryId,
  ) =>
      (_selectToday()..where((t) => t.dictionaryId.equals(dictionaryId))).get();
}
