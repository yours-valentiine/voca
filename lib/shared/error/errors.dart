// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// errors.dart
abstract class VocaError implements Exception {
  final String message;

  VocaError({required this.message});
}

class WordNotFound extends VocaError {
  WordNotFound({required super.message});

  @override
  String toString() => "Word not found: $message";
}

class DictionaryNotFound extends VocaError {
  DictionaryNotFound({required super.message});

  @override
  String toString() => "Dictionary not found: $message";
}
