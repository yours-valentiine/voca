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
import 'package:voca/shared/service/voca_preferences.dart';

part 'settings_notifier.freezed.dart';

class SettingsNotifier extends Notifier<SettingsData> {
  late final VocaSettings _settings = ref.watch(vocaSettingsProvider);
  late final BackupService _backupService = ref.watch(backupServiceProvider);

  @override
  SettingsData build() {
    return _initialization();
  }

  SettingsData _initialization() {
    final color = _settings.getColorSeed();

    return SettingsData(
      color: color,
      locale: LocaleSettings.currentLocale,
      isImporting: false,
    );
  }

  Future<void> setColor(Color color) async {
    await _settings.setColorSeed(color);
    state = state.copyWith(color: color);
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
}

@freezed
class SettingsData with _$SettingsData {
  const SettingsData({
    required this.color,
    required this.locale,
    required this.isImporting,
  });

  final Color color;
  final AppLocale locale;
  final bool isImporting;
}
