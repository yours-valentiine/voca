// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// views.dart
import 'package:drift/drift.dart';
import 'package:voca/data/local/tables.dart';

abstract class WordFull extends View {
  WordEntity get words;
  TranslateEntity get translates;

  @override
  Query<HasResultSet, dynamic> as() =>
      select([
        words.wordId,
        words.word,
        words.transcription,
        words.note,
        words.dictionaryId,
        translates.translateId,
        translates.translate,
        translates.position,
      ]).from(words).join([
        leftOuterJoin(translates, translates.wordId.equalsExp(words.wordId)),
      ]);
}

abstract class FsrsFull extends View {
  WordEntity get words;
  FsrsEntity get fsrs;
  FsrsHistoryEntity get fsrsHistory;

  @override
  Query<HasResultSet, dynamic> as() =>
      select([
        words.wordId,
        fsrs.state,
        fsrs.step,
        fsrs.difficulty,
        fsrs.stability,
        fsrs.due,
        fsrs.lastReview,
        fsrsHistory.timestampReview,
        fsrsHistory.state,
        fsrsHistory.raiting,
      ]).from(words).join([
        leftOuterJoin(fsrs, fsrs.wordId.equalsExp(words.wordId)),
        leftOuterJoin(fsrsHistory, fsrsHistory.wordId.equalsExp(words.wordId)),
      ]);
}

abstract class WordRepeat extends View {
  WordEntity get words;
  TranslateEntity get translates;
  FsrsEntity get fsrs;

  @override
  Query<HasResultSet, dynamic> as() =>
      select([
        words.wordId,
        words.dictionaryId,
        fsrs.due,
        fsrs.stability,
        fsrs.difficulty,
        fsrs.state,
        fsrs.step,
        fsrs.lastReview,
      ]).from(words).join([
        innerJoin(translates, translates.wordId.equalsExp(words.wordId)),
        leftOuterJoin(fsrs, fsrs.wordId.equalsExp(words.wordId)),
      ]);
}

abstract class WordRepeatFull extends View {
  WordEntity get words;
  TranslateEntity get translates;
  FsrsEntity get fsrs;

  @override
  Query<HasResultSet, dynamic> as() =>
      select([
        words.wordId,
        words.word,
        words.updatedAt,
        words.dictionaryId,
        translates.translateId,
        translates.translate,
        fsrs.due,
        fsrs.stability,
        fsrs.difficulty,
        fsrs.state,
        fsrs.step,
        fsrs.lastReview,
      ]).from(words).join([
        innerJoin(translates, translates.wordId.equalsExp(words.wordId)),
        leftOuterJoin(fsrs, fsrs.wordId.equalsExp(words.wordId)),
      ]);
}
