import 'package:connect_5/localization/localized_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocale {
  final String name;
  final Locale locale;

  const AppLocale(this.name, this.locale);
}

const SUPPORTED_LOCALES = [
  AppLocale('English', Locale('en')),
  AppLocale('简体中文', Locale('zh')),
];

bool isLocaleSupported(String languageCode) {
  return SUPPORTED_LOCALES.firstWhere((l) => l.locale.languageCode == languageCode) != null;
}

// See https://flutter.dev/docs/development/accessibility-and-localization/internationalization#alternative-class

/// Localize a string to the app's current locale
String localize(BuildContext context, String str) => AppLocalizations.of(context).localize(str);

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String localize(String str) => LOCALIZED_STRINGS[locale.languageCode][str] ?? str;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => isLocaleSupported(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
