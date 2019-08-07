import 'package:connect_5/localization/localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  bool isSupported(Locale locale) => SUPPORTED_LOCALES.firstWhere((l) => l.languageCode == locale.languageCode) != null;

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
