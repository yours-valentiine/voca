// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// dependecies.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca/features/updating/updating_notifier.dart';
import 'package:voca/shared/service/backup/backup_service.dart';
import 'package:voca/data/local/daos.dart';
import 'package:voca/data/local/database.dart';
import 'package:voca/data/repository/fsrs_repository.dart';
import 'package:voca/features/edit_dictionary/edit_dictionary_notifier.dart';
import 'package:voca/features/dictionary/dictionary_notifier.dart';
import 'package:voca/features/edit_word/edit_word_notifier.dart';
import 'package:voca/features/root/root_notifier.dart';
import 'package:voca/features/settings/settings_notifier.dart';
import 'package:voca/features/spaced_repetition/spaced_repetition_notifier.dart';
import 'package:voca/features/word/word_notifier.dart';
import 'package:voca/shared/notifier/current_dictionary_notifier.dart';
import 'package:voca/data/repository/dictionary_repository.dart';
import 'package:voca/shared/service/updater/updater_service.dart';
import 'package:voca/shared/service/preferences/voca_preferences.dart';

// #region Local database
final databaseProvider = Provider<VocaDatabase>((ref) => VocaDatabase());

final dictionaryDaoProvider = Provider<DictionaryDao>(
  (ref) => ref.read(databaseProvider).dictionaryDao,
);

final wordDaoProvider = Provider<WordDao>(
  (ref) => ref.read(databaseProvider).wordDao,
);

final translateDaoProvider = Provider<TranslateDao>(
  (ref) => ref.read(databaseProvider).translateDao,
);

final fsrsDaoProvider = Provider<FsrsDao>(
  (ref) => ref.read(databaseProvider).fsrsDao,
);

final wordRepeatDaoProvider = Provider<WordRepeatDao>(
  (ref) => ref.read(databaseProvider).wordRepeatDao,
);

final wordFullDaoProvider = Provider<WordFullDao>(
  (ref) => ref.read(databaseProvider).wordFullDao,
);

final wordRepeatFullDaoProvider = Provider<WordRepeatFullDao>(
  (ref) => ref.read(databaseProvider).wordRepeatFullDao,
);

final dictionaryRepositoryProvider = Provider<DictionaryRepository>(
  (ref) => DictionaryRepository(
    wordDao: ref.watch(wordDaoProvider),
    dictionaryDao: ref.watch(dictionaryDaoProvider),
    translateDao: ref.watch(translateDaoProvider),
    wordFullDao: ref.watch(wordFullDaoProvider),
  ),
);

final fsrsRepositoryProvider = Provider<FsrsRepository>(
  (ref) => FsrsRepository(
    fsrsDao: ref.watch(fsrsDaoProvider),
    wordRepeatFullDao: ref.watch(wordRepeatFullDaoProvider),
    wordRepeatDao: ref.watch(wordRepeatDaoProvider),
  ),
);

// #endregion

// #region Utils

final vocaSettingsProvider = Provider<VocaSettings>((ref) => VocaSettings());

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    vocaDatabase: ref.watch(databaseProvider),
    dictionaryRepository: ref.watch(dictionaryRepositoryProvider),
  ),
);

final updaterServiceProvider = Provider<UpdaterService>(
  (ref) => UpdaterService(settings: ref.watch(vocaSettingsProvider)),
);

// #endregion

// #region NOTIFIERS

final settingsNotifierProvider = NotifierProvider.autoDispose(
  SettingsNotifier.new,
);

final currentDictionaryNotifierProvider = AsyncNotifierProvider(
  CurrentDictionaryNotifier.new,
);

final rootNotifierProvider = StreamNotifierProvider.autoDispose(
  RootNotifier.new,
);

final editDictionaryNotifierProvider = AsyncNotifierProvider.autoDispose.family(
  EditDictionaryNotifier.new,
);

final dictionaryNotifierProvider = StreamNotifierProvider.autoDispose(
  DictionaryNotifier.new,
);

final wordNotifierProvider = AsyncNotifierProvider.autoDispose.family(
  WordNotifier.new,
);

final editWordNotifierProvider = AsyncNotifierProvider.autoDispose.family(
  EditWordNotifier.new,
);

final spacedRepetitionNotifierProvider = AsyncNotifierProvider.autoDispose(
  SpacedRepetitionNotifier.new,
);

final updatingNotifierProvider = NotifierProvider.autoDispose.family(
  UpdatingNotifier.new,
);
// #endregion
