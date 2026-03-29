// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// context_helpers.dart
import 'package:flutter/material.dart';
import 'package:voca/i18n/strings.g.dart';

TextTheme typography(BuildContext context) => Theme.of(context).textTheme;
ColorScheme colorScheme(BuildContext context) => Theme.of(context).colorScheme;
Translations translations(BuildContext context) => Translations.of(context);
