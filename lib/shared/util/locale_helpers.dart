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
