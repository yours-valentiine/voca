import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:voca/data/local/daos.dart';
import 'package:voca/data/local/database.dart';
import 'package:voca/shared/error/errors.dart';
import 'package:voca/shared/model/dictionary_model.dart';
import 'package:voca/shared/model/translate_model.dart';
import 'package:voca/shared/model/word_model.dart';
import 'package:voca/shared/util/object_helper.dart';

// TODO: Localize error message
class DictionaryRepository {
  final DictionaryDao dictionaryDao;
  final WordDao wordDao;
  final TranslateDao translateDao;
  final WordFullDao wordFullDao;

  DictionaryRepository({
    required this.wordDao,
    required this.dictionaryDao,
    required this.translateDao,
    required this.wordFullDao,
  });

  // #region Work with Dictionary
  Future<UuidValue> addSingleDictionary(DictionaryModel dictionary) async {
    final data = DictionaryEntityCompanion(
      dictionaryId: Value(dictionary.dictionaryId.toBytes()),
      name: Value(dictionary.name),
    );

    final inserted = await dictionaryDao.addSingle(data);

    return UuidValue.fromByteList(inserted.dictionaryId);
  }

  Future<DictionaryModel> getSingleDictionary(UuidValue id) async {
    final data = await dictionaryDao.getSingle(id.toBytes());

    if (data case null) {
      // TODO
      throw DictionaryNotFound(message: "dictionary with $id not found");
    }

    return DictionaryModel(
      dictionaryId: UuidValue.fromByteList(data.dictionaryId),
      name: data.name,
    );
  }

  Future<DictionaryModel> getFirstDictionary() async {
    final data = await dictionaryDao.getSingleOrNull();

    if (data case null) {
      // TODO
      throw DictionaryNotFound(message: "dictionary table is empty");
    }

    return DictionaryModel(
      dictionaryId: UuidValue.fromByteList(data.dictionaryId),
      name: data.name,
    );
  }

  Stream<List<DictionaryModel>> getAllDictionary() =>
      dictionaryDao.watchAll().map((list) {
        var newData = <DictionaryModel>[];
        for (var item in list) {
          newData.add(
            DictionaryModel(
              dictionaryId: UuidValue.fromByteList(item.dictionaryId),
              name: item.name,
            ),
          );
        }
        return newData;
      });
  // #endregion

  // #region Work with Word
  Future<WordModel?> getSingleWord(UuidValue wordId) async {
    final data = await wordFullDao.getSingle(wordId.toBytes());

    if (data.isEmpty) {
      return null;
    }

    final firstRow = data.first;

    var word = WordModel(
      wordId: wordId,
      word: firstRow.word,
      transcription: firstRow.transcription,
      note: firstRow.note,
      dictionaryId: UuidValue.fromByteList(firstRow.dictionaryId),
      translates: [],
    );

    for (var row in data) {
      if (row.translateId != null && row.translate != null) {
        final translate = TranslateModel(
          translateId: UuidValue.fromByteList(row.translateId!),
          translate: row.translate!,
          position: row.position!,
        );

        word = word.copyWith(translates: [...word.translates, translate]);
      }
    }

    return word;
  }

  Stream<List<WordModel>> watchForDictionary(UuidValue dictionaryId) =>
      wordFullDao.watchForDictionary(dictionaryId.toBytes()).map((data) {
        final mapOfWords = <UuidValue, WordModel>{};

        for (var row in data) {
          final currentId = UuidValue.fromByteList(row.wordId);

          final currentWord = mapOfWords.putIfAbsent(
            currentId,
            () => WordModel(
              wordId: currentId,
              word: row.word,
              transcription: row.transcription,
              note: row.note,
              dictionaryId: UuidValue.fromByteList(row.dictionaryId),
              translates: [],
            ),
          );

          if (row.translateId.isNotNull && row.translate.isNotNull) {
            final translate = TranslateModel(
              translateId: UuidValue.fromByteList(row.translateId!),
              translate: row.translate!,
              position: row.position!,
            );

            mapOfWords[currentId] = currentWord.copyWith(
              translates: [...currentWord.translates, translate],
            );
          }
        }

        return mapOfWords.values.toList();
      });

  Future<void> addSingleWord(WordModel word) async {
    await wordFullDao.attachedDatabase.transaction(() async {
      late final WordEntityData savedWord;
      /*
       * If word's id is null, then insert into table.
       * Else update
       */
      if (word.wordId == null) {
        final newWord = WordEntityCompanion.insert(
          word: word.word,
          transcription: Value(word.transcription?.trim()),
          note: Value(word.note?.trim()),
          dictionaryId: word.dictionaryId.toBytes(),
        );

        savedWord = await wordDao.upsertSingle(newWord);
      } else {
        final updatedWord = WordEntityCompanion(
          wordId: Value(word.wordId!.toBytes()),
          word: Value(word.word),
          transcription: Value(word.transcription),
          note: Value(word.note),
          dictionaryId: Value(word.dictionaryId.toBytes()),
        );

        savedWord = await wordDao.upsertSingle(updatedWord);
      }

      /*
       * Get old translates, then find ids which not in translate list.
       * Delete finding old tranlates, add insert/update other.
       */

      final oldTranslates = await translateDao.getByWordId(savedWord.wordId);
      final existingsIds = oldTranslates.map((t) => t.translateId).toSet();

      final newItemsIds = word.translates
          .map((t) => t.translateId.toBytes())
          .toSet();

      for (final existing in existingsIds) {
        if (!newItemsIds.any((newId) => listEquals(newId, existing))) {
          await translateDao.deleteSingle(existing);
        }
      }

      final newTranslates = word.translates.indexed
          .map(
            (translate) => TranslateEntityCompanion(
              translateId: Value(translate.$2.translateId.toBytes()),
              translate: Value(translate.$2.translate),
              wordId: Value(savedWord.wordId),
              position: Value(translate.$1),
            ),
          )
          .toList();

      await translateDao.addBatch(newTranslates);
    });
  }

  Future<void> deleteSingle(UuidValue wordId) async {
    await wordDao.deleteSingle(wordId.toBytes());
  }

  // #endregion
}
