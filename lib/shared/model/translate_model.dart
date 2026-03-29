// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// translate_model.dart
// ignore_for_file: annotate_overrides

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'translate_model.freezed.dart';

@freezed
class TranslateModel with _$TranslateModel {
  TranslateModel({
    required this.translateId,
    required this.translate,
    required this.position,
  });

  final UuidValue translateId;
  final String translate;
  final int position;
}
