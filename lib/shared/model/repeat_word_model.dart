import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fsrs/fsrs.dart' show State;
import 'package:uuid/uuid.dart';
import 'package:voca/shared/model/translate_model.dart';

part 'repeat_word_model.freezed.dart';

@freezed
class RepeatWordModel with _$RepeatWordModel {
  const RepeatWordModel({
    required this.wordId,
    required this.word,
    required this.updatedAt,
    required this.dictionaryId,
    required this.translates,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.state,
    required this.step,
    required this.lastReview,
  });

  final UuidValue wordId;
  final String word;
  final DateTime updatedAt;
  final UuidValue dictionaryId;
  final List<TranslateModel> translates;
  final DateTime? due;
  final double? stability;
  final double? difficulty;
  final State? state;
  final int? step;
  final DateTime? lastReview;
}
