// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// voca_preferences.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:voca/i18n/strings.g.dart';

class VocaSettings {
  // #region KEYS
  static const String _colorSeed = "color_seed";
  static const String _currentDictionaryKey = "current_dictionary";
  static const String _storedLocale = "stored_locale";
  static const String _allowPrereleaseKey = "allow_prerealese";
  static const String _dateCheckUpdate = "latest_check_update";
  // #endregion

  late final SharedPreferences prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  // #region Setters
  Future<void> setColorSeed(Color color) =>
      prefs.setInt(_colorSeed, color.toARGB32());

  Future<void> setDictionaryId(UuidValue id) =>
      prefs.setString(_currentDictionaryKey, id.uuid);

  Future<void> setAppLocale(AppLocale locale) =>
      prefs.setString(_storedLocale, locale.languageCode);

  Future<void> setAllowPrerelease(bool allow) =>
      prefs.setBool(_allowPrereleaseKey, allow);

  Future<void> setDateCheckUpdate(DateTime date) =>
      prefs.setInt(_dateCheckUpdate, date.millisecondsSinceEpoch);
  // #endregion

  // #region Getters

  Color get getColorSeed =>
      Color(prefs.getInt(_colorSeed) ?? Colors.amber.toARGB32());

  UuidValue? get getDictionaryId {
    final rawId = prefs.getString(_currentDictionaryKey);
    if (rawId case null) return null;
    return UuidValue.fromString(rawId);
  }

  AppLocale? get getStoredLocale {
    final stored = prefs.getString(_storedLocale);
    if (stored == null) return null;
    return AppLocaleUtils.parse(stored);
  }

  bool get getAllowPrerelease => prefs.getBool(_allowPrereleaseKey) ?? false;

  DateTime? get getDateCheckUpdate {
    final unixTime = prefs.getInt(_dateCheckUpdate);
    if (unixTime == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(unixTime);
  }

  // #endregion
}
