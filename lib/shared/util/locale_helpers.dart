// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// locale_helpers.dart
import 'package:voca/i18n/strings.g.dart';

extension LocaleHelpers on AppLocale {
  String toDisplay() => switch (this) {
    AppLocale.en => "English",
    AppLocale.ru => "Русский",
    AppLocale.de => "Deutsch",
    AppLocale.fr => "Le français",
    AppLocale.es => "Español",
  };
}
