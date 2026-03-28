import 'package:flutter/material.dart';
import 'package:voca/i18n/strings.g.dart';

TextTheme typography(BuildContext context) => Theme.of(context).textTheme;
ColorScheme colorScheme(BuildContext context) => Theme.of(context).colorScheme;
Translations translations(BuildContext context) => Translations.of(context);
