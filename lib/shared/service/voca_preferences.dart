// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// voca_preferences.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class VocaSettings {
  // #region KEYS
  static const String _colorSeed = "color_seed";
  static const String _currentDictionaryKey = "current_dictionary";
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
  Future<void> setColorSeed(Color color) async =>
      await prefs.setInt(_colorSeed, color.toARGB32());

  Future<void> setDictionaryId(UuidValue id) async =>
      await prefs.setString(_currentDictionaryKey, id.uuid);

  // #endregion

  // #region Getters

  Color getColorSeed({Color defaultColor = Colors.amber}) =>
      Color(prefs.getInt(_colorSeed) ?? defaultColor.toARGB32());

  UuidValue? get getDictionaryId {
    final rawId = prefs.getString(_currentDictionaryKey);
    if (rawId case null) return null;
    return UuidValue.fromString(rawId);
  }

  // #endregion
}
