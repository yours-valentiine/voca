import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/shared/model/dictionary_model.dart';
import 'package:voca/data/repository/dictionary_repository.dart';

class RootNotifier extends StreamNotifier<List<DictionaryModel>> {
  late final DictionaryRepository _dictionaryRepository = ref.watch(
    dictionaryRepositoryProvider,
  );

  @override
  Stream<List<DictionaryModel>> build() {
    return _dictionaryRepository.getAllDictionary();
  }
}
