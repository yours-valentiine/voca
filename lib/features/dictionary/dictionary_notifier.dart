// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// dictionary_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid_value.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/shared/model/word_model.dart';
import 'package:voca/data/repository/dictionary_repository.dart';

class DictionaryNotifier extends StreamNotifier<List<WordModel>> {
  late final DictionaryRepository _dictionaryRepository = ref.watch(
    dictionaryRepositoryProvider,
  );

  @override
  Stream<List<WordModel>> build() {
    final currentDictionary = ref.watch(currentDictionaryNotifierProvider);

    return currentDictionary.when(
      data: (data) =>
          _dictionaryRepository.watchForDictionary(data.dictionaryId),
      error: (error, stackTrace) => throw error,
      loading: () => Stream.empty(),
    );
  }

  Future<void> deleteWord(UuidValue wordId) async {
    try {
      await _dictionaryRepository.deleteSingleWord(wordId);
    } catch (err, stackTrace) {
      state = AsyncValue.error(err, stackTrace);
    }
  }
}
