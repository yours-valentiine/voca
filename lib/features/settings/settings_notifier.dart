import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/i18n/strings.g.dart';
import 'package:voca/shared/service/voca_preferences.dart';

part 'settings_notifier.freezed.dart';

class SettingsNotifier extends Notifier<SettingsData> {
  late final VocaSettings _settings = ref.watch(vocaSettingsProvider);

  @override
  SettingsData build() {
    return _initialization();
  }

  SettingsData _initialization() {
    final color = _settings.getColorSeed();

    return SettingsData(color: color, locale: LocaleSettings.currentLocale);
  }

  Future<void> setColor(Color color) async {
    await _settings.setColorSeed(color);
    state = state.copyWith(color: color);
  }
}

@freezed
class SettingsData with _$SettingsData {
  const SettingsData({required this.color, required this.locale});

  final Color color;
  final AppLocale locale;
}
