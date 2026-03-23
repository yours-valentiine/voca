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
