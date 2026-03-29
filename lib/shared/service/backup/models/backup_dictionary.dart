// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// backup_dictionary.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/parsing.dart';
import 'package:voca/data/local/database.dart';

part 'backup_dictionary.g.dart';

@JsonSerializable()
class BackupDictionary {
  final String dictionaryId;
  final String name;
  final int updatedAt;

  const BackupDictionary({
    required this.dictionaryId,
    required this.name,
    required this.updatedAt,
  });

  factory BackupDictionary.fromJson(Map<String, dynamic> json) =>
      _$BackupDictionaryFromJson(json);
  Map<String, dynamic> toJson() => _$BackupDictionaryToJson(this);

  DictionaryEntityData toModel() => DictionaryEntityData(
    dictionaryId: UuidParsing.parseAsByteList(dictionaryId),
    name: name,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
  );
}
