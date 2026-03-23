import 'package:drift/drift.dart';
import 'package:fsrs/fsrs.dart' show State, Rating;
import 'package:voca/shared/util/utils.dart';

class DictionaryEntity extends Table {
  BlobColumn get dictionaryId =>
      blob().clientDefault(() => generateUuid().toBytes())();
  TextColumn get name => text()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.timestamp())();

  @override
  Set<Column<Object>>? get primaryKey => {dictionaryId};

  @override
  bool get withoutRowId => true;

  @override
  bool get isStrict => true;
}

@TableIndex(name: "idx_word_word", columns: {#word})
class WordEntity extends Table {
  BlobColumn get wordId =>
      blob().clientDefault(() => generateUuid().toBytes())();
  TextColumn get word => text().check(word.length.isBiggerOrEqualValue(1))();
  TextColumn get transcription => text().nullable()();
  TextColumn get note => text().nullable()();
  BlobColumn get dictionaryId => blob().references(
    DictionaryEntity,
    #dictionaryId,
    onDelete: .cascade,
    onUpdate: .cascade,
  )();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.timestamp())();

  @override
  Set<Column<Object>>? get primaryKey => {wordId};

  @override
  bool get withoutRowId => true;

  @override
  bool get isStrict => true;
}

@TableIndex(name: "idx_translate_translate", columns: {#translate})
class TranslateEntity extends Table {
  BlobColumn get translateId =>
      blob().clientDefault(() => generateUuid().toBytes())();
  TextColumn get translate =>
      text().check(translate.length.isBiggerOrEqualValue(1))();
  BlobColumn get wordId => blob().references(
    WordEntity,
    #wordId,
    onDelete: .cascade,
    onUpdate: .cascade,
  )();
  IntColumn get position => integer()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.timestamp())();

  @override
  Set<Column<Object>>? get primaryKey => {translateId};

  @override
  bool get withoutRowId => true;

  @override
  bool get isStrict => true;
}

class FsrsEntity extends Table {
  BlobColumn get wordId => blob().references(
    WordEntity,
    #wordId,
    onUpdate: .cascade,
    onDelete: .cascade,
  )();
  TextColumn get state => textEnum<State>()();
  IntColumn get step => integer().nullable()();
  RealColumn get stability => real()();
  RealColumn get difficulty => real()();
  DateTimeColumn get due => dateTime()();
  DateTimeColumn get lastReview => dateTime().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {wordId};

  @override
  bool get withoutRowId => true;

  @override
  bool get isStrict => true;
}

class FsrsHistoryEntity extends Table {
  DateTimeColumn get timestampReview => dateTime()();
  BlobColumn get wordId => blob().references(
    WordEntity,
    #wordId,
    onUpdate: .cascade,
    onDelete: .cascade,
  )();
  TextColumn get state => textEnum<State>()();
  TextColumn get raiting => textEnum<Rating>()();

  @override
  Set<Column<Object>>? get primaryKey => {timestampReview};

  @override
  bool get withoutRowId => true;

  @override
  bool get isStrict => true;
}
