// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// errors.dart
sealed class DatabaseError implements Exception {
  final String message;

  DatabaseError({required this.message});
}

class WordNotFoundError extends DatabaseError {
  WordNotFoundError({required super.message});

  @override
  String toString() => "Word not found: $message";
}

class DictionaryNotFoundError extends DatabaseError {
  DictionaryNotFoundError({required super.message});

  @override
  String toString() => "Dictionary not found: $message";
}
