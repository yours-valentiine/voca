import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/parsing.dart';
import 'package:voca/data/local/database.dart';

part 'backup_word.g.dart';

@JsonSerializable()
class BackupWord {
  final String wordId;
  final String word;
  final String? transcription;
  final String? note;
  final String dictionaryId;
  final int updatedAt;

  const BackupWord({
    required this.wordId,
    required this.word,
    this.transcription,
    this.note,
    required this.dictionaryId,
    required this.updatedAt,
  });

  factory BackupWord.fromJson(Map<String, dynamic> json) =>
      _$BackupWordFromJson(json);
  Map<String, dynamic> toJson() => _$BackupWordToJson(this);

  WordEntityData toModel() => WordEntityData(
    wordId: UuidParsing.parseAsByteList(wordId),
    word: word,
    transcription: transcription,
    note: note,
    dictionaryId: UuidParsing.parseAsByteList(dictionaryId),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
  );
}
