import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/data/repository/dictionary_repository.dart';
import 'package:voca/shared/model/dictionary_model.dart';

class CreateDictionaryNotifier extends Notifier<DictionaryModel> {
  late final DictionaryRepository _dictionaryRepository = ref.watch(
    dictionaryRepositoryProvider,
  );

  @override
  DictionaryModel build() {
    return DictionaryModel(
      dictionaryId: UuidValue.fromString(Uuid().v7()),
      name: "",
    );
  }

  void setName(String value) => state = state.copyWith(name: value);

  Future<bool> saveData() async {
    try {
      final id = await _dictionaryRepository.addSingleDictionary(state);

      final notifier = ref.read(currentDictionaryNotifierProvider.notifier);
      notifier.changeCurrent(id);

      return true;
    } catch (e) {
      return false;
    }
  }
}
