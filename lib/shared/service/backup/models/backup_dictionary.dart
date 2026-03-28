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
