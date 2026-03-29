// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// word_model.dart
// ignore_for_file: annotate_overrides

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:voca/shared/model/translate_model.dart';

part 'word_model.freezed.dart';

@freezed
class WordModel with _$WordModel {
  WordModel({
    this.wordId,
    required this.word,
    required this.transcription,
    required this.note,
    required this.dictionaryId,
    required this.translates,
  });

  final UuidValue? wordId;
  final String word;
  final String? transcription;
  final String? note;
  final UuidValue dictionaryId;
  final List<TranslateModel> translates;

  bool get isValid => word.isNotEmpty;
  String get formattedTranslates =>
      translates.map((t) => t.translate).join('; ');
}
