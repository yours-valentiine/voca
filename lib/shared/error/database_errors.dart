// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// errors.dart
sealed class DatabaseError implements Exception {
  final String message;
  final StackTrace? stackTrace;

  DatabaseError({required this.message, this.stackTrace});

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    return buffer.toString();
  }
}

class WordNotFoundError extends DatabaseError {
  final Object? wordId;

  WordNotFoundError({required this.wordId, super.stackTrace})
    : super(message: "Word with $wordId not found");
}

class DictionaryNotFoundError extends DatabaseError {
  final Object dictionaryId;

  DictionaryNotFoundError({required this.dictionaryId, super.stackTrace})
    : super(message: "Dictionary $dictionaryId not found");
}
