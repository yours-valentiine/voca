// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// backup_translate.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/parsing.dart';
import 'package:voca/data/local/database.dart';

part 'backup_translate.g.dart';

@JsonSerializable()
class BackupTranslate {
  final String translateId;
  final String translate;
  final int position;
  final String wordId;
  final int updatedAt;

  const BackupTranslate({
    required this.translateId,
    required this.translate,
    required this.position,
    required this.wordId,
    required this.updatedAt,
  });

  factory BackupTranslate.fromJson(Map<String, dynamic> json) =>
      _$BackupTranslateFromJson(json);
  Map<String, dynamic> toJson() => _$BackupTranslateToJson(this);

  TranslateEntityData toModel() => TranslateEntityData(
    translateId: UuidParsing.parseAsByteList(translateId),
    translate: translate,
    wordId: UuidParsing.parseAsByteList(wordId),
    position: position,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
  );
}
