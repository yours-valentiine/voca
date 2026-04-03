// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:voca/features/edit_dictionary/edit_dictionary_dialog.dart';
import 'package:voca/features/dictionary/dictionary_screen.dart';
import 'package:voca/features/edit_word/edit_word_screen.dart';
import 'package:voca/features/repeat/repeat_screen.dart';
import 'package:voca/features/root/root_shell.dart';
import 'package:voca/features/settings/settings_screen.dart';
import 'package:voca/features/spaced_repetition/spaced_repetition_screen.dart';
import 'package:voca/features/updating/updating_screen.dart';
import 'package:voca/features/word/word_screen.dart';
import 'package:voca/router/dialog_page.dart';
import 'package:voca/router/routes.dart';
import 'package:voca/shared/service/updater/models/version_model.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => Routes.dictionary.location,
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.dictionary.location,
              pageBuilder: (context, state) =>
                  const MaterialPage(child: DictionaryScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.exercises.location,
              pageBuilder: (context, state) =>
                  const MaterialPage(child: RepeatScreen()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.word.location,
      pageBuilder: (context, state) {
        final wordId = state.extra as UuidValue;

        return MaterialPage(child: WordScreen(wordId: wordId));
      },
    ),
    GoRoute(
      path: Routes.editWord.location,
      pageBuilder: (context, state) {
        final wordId = state.extra as UuidValue?;
        return MaterialPage(
          fullscreenDialog: true,
          child: EditWordScreen(wordId: wordId),
        );
      },
    ),
    GoRoute(
      path: Routes.editDictionary.location,
      pageBuilder: (context, state) {
        final dictionaryId = state.extra as UuidValue?;

        return DialogPage(
          child: EditDictionaryDialog(dictionaryId: dictionaryId),
        );
      },
    ),
    GoRoute(
      path: Routes.spacedRepetition.location,
      pageBuilder: (context, state) =>
          const MaterialPage(child: SpacedRepetitionScreen()),
    ),
    GoRoute(
      path: Routes.settings.location,
      pageBuilder: (context, state) =>
          const MaterialPage(child: SettingsScreen()),
    ),
    GoRoute(
      path: Routes.updating.location,
      pageBuilder: (context, state) {
        final model = state.extra as VersionModel;
        return MaterialPage(
          child: UpdatingScreen(model: model),
          fullscreenDialog: true,
        );
      },
    ),
  ],
);
