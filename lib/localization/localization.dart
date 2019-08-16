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
  AppLocale('简体中文', Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')),
  AppLocale('繁體中文', Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')),
];

bool isLanguageCodeSupported(String languageCode) {
  return SUPPORTED_LOCALES.firstWhere((l) => l.locale.languageCode == languageCode, orElse: () => null) != null;
}

bool isLocaleSupported(Locale locale) {
  return SUPPORTED_LOCALES.firstWhere(
    (l) => l.locale.languageCode == locale.languageCode && l.locale.scriptCode == locale.scriptCode,
    orElse: () => null
  ) != null;
}

// See https://flutter.dev/docs/development/accessibility-and-localization/internationalization#alternative-class

/// Localize a string to the app's current locale
/// If [replacements] is given, then it will replace keys in the localized string with value
String localize(BuildContext context, String str, [Map<String, String> replacements]) {
  if (replacements == null) {
    return AppLocalizations.of(context).localize(str);
  }
  var localized = localize(context, str);
  replacements.forEach((key, value) {
    localized = localized.replaceAll(key, value);
  });
  return localized;
}

String getLocaleString(Locale locale) => locale.scriptCode == null
  ? locale.languageCode
  : '${locale.languageCode}_${locale.scriptCode}';

class AppLocalizations {
  AppLocalizations(this.locale)
    : localeKey = isLocaleSupported(locale) ? getLocaleString(locale) : locale.languageCode;

  final Locale locale;
  final String localeKey;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String localize(String str) => LOCALIZED_STRINGS[localeKey][str] ?? str;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => isLanguageCodeSupported(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
