// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'dictionary_model.freezed.dart';

@freezed
class DictionaryModel with _$DictionaryModel {
  const DictionaryModel({required this.dictionaryId, required this.name});

  final UuidValue dictionaryId;
  final String name;
}
