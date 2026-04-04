// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// fsrs_repository.dart
import 'package:drift/drift.dart';
import 'package:fsrs/fsrs.dart' show Card, Rating;
import 'package:uuid/uuid_value.dart';
import 'package:voca/data/local/daos.dart';
import 'package:voca/data/local/database.dart';
import 'package:voca/shared/model/repeat_word_model.dart';
import 'package:voca/shared/model/translate_model.dart';

class FsrsRepository {
  FsrsRepository({
    required this.fsrsDao,
    required this.wordRepeatFullDao,
    required this.wordRepeatDao,
  });

  final FsrsDao fsrsDao;
  final WordRepeatFullDao wordRepeatFullDao;
  final WordRepeatDao wordRepeatDao;

  Stream<int> watchCount(UuidValue dictionaryId) =>
      wordRepeatDao.watchToday(dictionaryId.toBytes()).map((w) => w.length);

  Stream<int> watchNewCount(UuidValue dictionaryId) =>
      wordRepeatDao.watchNewCount(dictionaryId.toBytes());

  Future<List<RepeatWordModel>> getToday(UuidValue dictionaryId) async {
    final data = await wordRepeatFullDao.getTodayForDictionary(
      dictionaryId.toBytes(),
    );

    var cards = <UuidValue, RepeatWordModel>{};

    for (var row in data) {
      final current = cards.putIfAbsent(
        UuidValue.fromByteList(row.wordId),
        () => RepeatWordModel(
          wordId: UuidValue.fromByteList(row.wordId),
          word: row.word,
          updatedAt: row.updatedAt,
          dictionaryId: dictionaryId,
          translates: [],
          due: row.due,
          stability: row.stability,
          difficulty: row.difficulty,
          state: row.state,
          step: row.step,
          lastReview: row.lastReview,
        ),
      );

      cards[current.wordId] = current.copyWith(
        translates: [
          ...current.translates,
          TranslateModel(
            translateId: UuidValue.fromByteList(row.translateId),
            translate: row.translate,
            position: 0,
          ),
        ],
      );
    }

    return cards.values.toList();
  }

  Future<void> addSingle({
    required UuidValue wordId,
    required Card card,
    required Rating rating,
  }) async => await fsrsDao.addSingle(
    FsrsEntityCompanion.insert(
      wordId: wordId.toBytes(),
      state: card.state,
      step: Value(card.step),
      stability: card.stability!,
      difficulty: card.difficulty!,
      due: card.due,
      lastReview: Value(DateTime.timestamp()),
    ),
    rating: rating,
  );
}
