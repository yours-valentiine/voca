import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/data/repository/dictionary_repository.dart';
import 'package:voca/shared/model/dictionary_model.dart';
import 'package:voca/shared/util/utils.dart';

class EditDictionaryNotifier extends AsyncNotifier<DictionaryModel> {
  late final DictionaryRepository _dictionaryRepository = ref.watch(
    dictionaryRepositoryProvider,
  );

  EditDictionaryNotifier(this.dictionaryId);

  final UuidValue? dictionaryId;

  @override
  Future<DictionaryModel> build() async {
    return await _load();
  }

  Future<DictionaryModel> _load() async {
    if (dictionaryId == null) {
      return DictionaryModel(
        dictionaryId: generateUuid(),
        name: "",
      );
    } else {
      final dataFromDb = await _dictionaryRepository.getSingleDictionary(
        dictionaryId!,
      );
      return dataFromDb;
    }
  }

  void setName(String value) =>
      state = state.whenData((data) => data.copyWith(name: value));

  Future<bool> saveData() async {
    try {
      final currentData = state.requireValue;
      final id = await _dictionaryRepository.addSingleDictionary(currentData);

      final notifier = ref.read(currentDictionaryNotifierProvider.notifier);
      notifier.changeCurrent(id);

      return true;
    } catch (e) {
      return false;
    }
  }
}
