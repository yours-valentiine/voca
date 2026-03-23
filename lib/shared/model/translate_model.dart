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
