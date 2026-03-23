import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid_value.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/shared/model/dictionary_model.dart';
import 'package:voca/data/repository/dictionary_repository.dart';
import 'package:voca/shared/service/voca_preferences.dart';

class CurrentDictionaryNotifier extends AsyncNotifier<DictionaryModel> {
  late final VocaSettings _preferences = ref.read(vocaSettingsProvider);
  late final DictionaryRepository _dictionaryRepository = ref.read(
    dictionaryRepositoryProvider,
  );

  @override
  Future<DictionaryModel> build() async {
    try {
      return await _load();
    } catch (e) {
      await refreshLocal();
      return await _load();
    }
  }

  Future<DictionaryModel> _load() async {
    var storedId = _preferences.getDictionaryId;

    if (storedId case null) {
      final fromDb = await _dictionaryRepository.getFirstDictionary();
      await _preferences.setDictionaryId(fromDb.dictionaryId);
      return fromDb;
    } else {
      return await _dictionaryRepository.getSingleDictionary(storedId);
    }
  }

  Future<void> refreshLocal() async {
    final fromDb = await _dictionaryRepository.getFirstDictionary();
    await _preferences.setDictionaryId(fromDb.dictionaryId);
  }

  Future<void> changeCurrent(UuidValue dictionaryId) async {
    try {
      final newModel = await _dictionaryRepository.getSingleDictionary(
        dictionaryId,
      );

      await _preferences.setDictionaryId(dictionaryId);
      state = AsyncValue.data(newModel);
    } catch (err, stackTrace) {
      state = AsyncValue.error(err, stackTrace);
    }
  }
}
