// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// edit_word_notifier.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/shared/error/database_errors.dart';
import 'package:voca/shared/model/translate_model.dart';
import 'package:voca/shared/model/word_model.dart';
import 'package:voca/data/repository/dictionary_repository.dart';

class EditWordNotifier extends AsyncNotifier<WordModel> {
  late final DictionaryRepository _dictionaryRepository = ref.watch(
    dictionaryRepositoryProvider,
  );

  EditWordNotifier(this.wordId);

  final UuidValue? wordId;

  @override
  Future<WordModel> build() async {
    if (wordId case null) {
      return await _createNew();
    }

    final stored = await _load(wordId!);

    return switch (stored) {
      null => throw WordNotFoundError(message: "$wordId"),
      WordModel() => stored,
    };
  }

  Future<WordModel> _createNew() async {
    final dictionary = await ref.read(currentDictionaryNotifierProvider.future);

    return WordModel(
      wordId: null,
      word: "",
      transcription: null,
      note: null,
      dictionaryId: dictionary.dictionaryId,
      translates: [],
    );
  }

  Future<WordModel?> _load(UuidValue id) async {
    final stored = await _dictionaryRepository.getSingleWordOrNull(id);
    return stored;
  }

  void setWord(String value) =>
      state = state.whenData((old) => old.copyWith(word: value));

  void setTranscription(String value) =>
      state = state.whenData((old) => old.copyWith(transcription: value));

  void setNote(String value) =>
      state = state.whenData((old) => old.copyWith(note: value));

  void setTranslate(UuidValue id, String value) => state = state.whenData(
    (old) => old.copyWith(
      translates: old.translates.map((t) {
        if (t.translateId == id) {
          return TranslateModel(
            translateId: t.translateId,
            translate: value,
            position: t.position,
          );
        }
        return t;
      }).toList(),
    ),
  );

  void appendTranslate() {
    state = state.whenData(
      (old) => old.copyWith(
        translates: [
          ...old.translates,
          TranslateModel(
            translateId: UuidValue.raw(Uuid().v4()),
            translate: "",
            position: old.translates.length - 1,
          ),
        ],
      ),
    );
  }

  void reorderTranslate(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    state = state.whenData((old) {
      final newTranslates = List<TranslateModel>.from(old.translates);

      final targetIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
      final reorderedTranslate = newTranslates.removeAt(oldIndex);
      newTranslates.insert(targetIndex, reorderedTranslate);

      return old.copyWith(translates: newTranslates);
    });
  }

  void removeTranslate(UuidValue id) => state = state.whenData(
    (old) => old.copyWith(
      translates: [...old.translates.where((t) => t.translateId != id)],
    ),
  );

  void clearTranslates() => state = state.whenData(
    (old) => old.copyWith(
      translates: [...old.translates.where((t) => t.translate.isNotEmpty)],
    ),
  );

  Future<bool> save() async {
    if (state.hasError || state.isLoading || state.value == null) {
      return false;
    }

    if (!state.value!.isValid) {
      return false;
    }

    await _dictionaryRepository.upsertSingleWord(state.value!);
    return true;
  }
}
