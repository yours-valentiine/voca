import 'package:fsrs/fsrs.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/parsing.dart';
import 'package:voca/data/local/database.dart';

part 'backup_fsrs.g.dart';

@JsonSerializable()
class BackupFsrs {
  final String wordId;
  final int state;
  final int? step;
  final double stability;
  final double difficulty;
  final int due;
  final int? lastReview;

  BackupFsrs({
    required this.wordId,
    required this.state,
    this.step,
    required this.stability,
    required this.difficulty,
    required this.due,
    this.lastReview,
  });

  factory BackupFsrs.fromJson(Map<String, dynamic> json) =>
      _$BackupFsrsFromJson(json);
  Map<String, dynamic> toJson() => _$BackupFsrsToJson(this);

  FsrsEntityData toModel() => FsrsEntityData(
    wordId: UuidParsing.parseAsByteList(wordId),
    state: State.fromValue(state),
    step: step,
    stability: stability,
    difficulty: difficulty,
    due: DateTime.fromMillisecondsSinceEpoch(due),
    lastReview: lastReview == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(lastReview!),
  );
}
