import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:voca/features/dictionary/dictionary_screen.dart';
import 'package:voca/features/edit_word/edit_word_screen.dart';
import 'package:voca/features/repeat/repeat_screen.dart';
import 'package:voca/features/root/root_shell.dart';
import 'package:voca/features/settings/settings_screen.dart';
import 'package:voca/features/spaced_repetition/spaced_repetition_screen.dart';
import 'package:voca/features/word/word_screen.dart';
import 'package:voca/router/routes.dart';

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
                  MaterialPage(child: DictionaryScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.exercises.location,
              pageBuilder: (context, state) =>
                  MaterialPage(child: RepeatScreen()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.word.location,
      pageBuilder: (context, state) {
        final wordId = state.pathParameters["id"]!;

        return MaterialPage(
          child: WordScreen(wordId: UuidValue.fromString(wordId)),
        );
      },
    ),
    GoRoute(
      path: Routes.editWord.location,
      pageBuilder: (context, state) {
        final wordId = state.pathParameters["id"];

        if (wordId != null && wordId.length == 36) {
          final formatted = UuidValue.fromString(wordId);
          return MaterialPage(
            fullscreenDialog: true,
            child: EditWordScreen(wordId: formatted),
          );
        }

        return MaterialPage(
          fullscreenDialog: true,
          child: EditWordScreen(wordId: null),
        );
      },
    ),
    GoRoute(
      path: Routes.spacedRepetition.location,
      pageBuilder: (context, state) =>
          MaterialPage(child: SpacedRepetitionScreen()),
    ),
    GoRoute(
      path: Routes.settings.location,
      pageBuilder: (context, state) => MaterialPage(child: SettingsScreen()),
    ),
  ],
);
