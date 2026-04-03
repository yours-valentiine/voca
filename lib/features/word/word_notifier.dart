// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// word_notifier.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/shared/error/database_errors.dart';
import 'package:voca/shared/model/word_model.dart';
import 'package:voca/data/repository/dictionary_repository.dart';

class WordNotifier extends AsyncNotifier<WordModel> {
  WordNotifier(this.wordId);

  final UuidValue wordId;

  late final DictionaryRepository _dictionaryRepository = ref.watch(
    dictionaryRepositoryProvider,
  );

  @override
  Future<WordModel> build() async {
    return await _load();
  }

  Future<WordModel> _load() async {
    final word = await _dictionaryRepository.getSingleWordOrNull(wordId);
    if (word case null) {
      throw WordNotFoundError(message: "Word with $wordId not found");
    }
    return word;
  }

  Future<void> refresh() async {
    try {
      final word = await _load();
      state = AsyncValue.data(word);
    } catch (err, stackTrace) {
      state = AsyncValue.error(err, stackTrace);
    }
  }
}
