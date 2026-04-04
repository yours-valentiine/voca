// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// settings_notifier.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/shared/service/backup/backup_service.dart';
import 'package:voca/i18n/strings.g.dart';
import 'package:voca/shared/service/updater/models/version_model.dart';
import 'package:voca/shared/service/updater/updater_service.dart';
import 'package:voca/shared/service/preferences/voca_preferences.dart';

part 'settings_notifier.freezed.dart';

class SettingsNotifier extends Notifier<SettingsData> {
  late final VocaSettings _settings = ref.watch(vocaSettingsProvider);
  late final BackupService _backupService = ref.watch(backupServiceProvider);
  late final UpdaterService _updaterService = ref.watch(updaterServiceProvider);

  @override
  SettingsData build() {
    return _initialization();
  }

  SettingsData _initialization() => SettingsData(
    color: _settings.getColorSeed,
    locale: LocaleSettings.currentLocale,
    isImporting: false,
    allowPrerelease: _settings.getAllowPrerelease,
    isCheckUpdate: false,
  );

  Future<void> setColor(Color color) async {
    await _settings.setColorSeed(color);
    state = state.copyWith(color: color);
  }

  Future<void> setAllowPrerelease(bool allow) async {
    await _settings.setAllowPrerelease(allow);
    state = state.copyWith(allowPrerelease: allow);
  }

  void setLocale(AppLocale locale) => state = state.copyWith(locale: locale);

  void cancelUpdateLocale() => state = state.copyWith(
    locale: _settings.getStoredLocale ?? LocaleSettings.currentLocale,
  );

  Future<bool> saveLocale() async {
    if (state.locale != LocaleSettings.currentLocale) {
      await _settings.setAppLocale(state.locale);
      return true;
    }

    return false;
  }

  Future<void> exportData(String outputPath) async {
    final data = await _backupService.createExport(tables: BackupTables.values);
    final outputFile = File(outputPath);

    if (!(await outputFile.exists())) {
      await outputFile.create(recursive: true);
    }

    await data.copy(outputPath);
  }

  Future<void> importData(String importPath) async {
    try {
      state = state.copyWith(isImporting: true);

      await _backupService.importData(backupPath: importPath);
    } finally {
      state = state.copyWith(isImporting: false);
    }
  }

  Future<VersionModel?> checkLatest() async {
    try {
      state = state.copyWith(isCheckUpdate: true);

      final latest = await _updaterService.checkUpdate(
        showPrerelease: _settings.getAllowPrerelease,
      );

      return latest;
    } catch (err) {
      return null;
    } finally {
      state = state.copyWith(isCheckUpdate: false);
    }
  }
}

@freezed
class SettingsData with _$SettingsData {
  const SettingsData({
    required this.color,
    required this.locale,
    required this.isImporting,
    required this.allowPrerelease,
    required this.isCheckUpdate,
  });

  final Color color;
  final AppLocale locale;
  final bool isImporting;
  final bool isCheckUpdate;
  final bool allowPrerelease;
}
