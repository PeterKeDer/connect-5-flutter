import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/helpers/stats_manager.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  final settingsManager = SettingsManager();
  final gameStorageManager = GameStorageManager();
  final statsManager = StatsManager();

  await Future.wait([
    gameStorageManager.readGamesAsync(),
    settingsManager.initAsync(),
    statsManager.initAsync(),
  ]);

  runApp(Connect5App(settingsManager, gameStorageManager, statsManager));
}

class Connect5App extends StatelessWidget {
  final SettingsManager settingsManager;
  final GameStorageManager gameStorageManger;
  final StatsManager statsManager;
  final MultiplayerManager multiplayerManager = MultiplayerManager();

  Connect5App(this.settingsManager, this.gameStorageManger, this.statsManager);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameStorageManager>.value(value: gameStorageManger),
        ChangeNotifierProvider<SettingsManager>.value(value: settingsManager),
        ChangeNotifierProvider<StatsManager>.value(value: statsManager),
        ChangeNotifierProvider<MultiplayerManager>.value(value: multiplayerManager),
      ],
      child: Builder(
        builder: (context) {
          final settingsManager = Provider.of<SettingsManager>(context);

          return MaterialApp(
            title: 'Connect 5',
            locale: settingsManager.locale,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              final savedLocale = settingsManager.locale;

              if (savedLocale == null) {
                Future.delayed(Duration.zero, () {
                  // Choose best supported locale to match
                  if (isLocaleSupported(deviceLocale)) {
                    settingsManager.localeString = getLocaleString(deviceLocale);
                  } else if (isLanguageCodeSupported(deviceLocale.languageCode)) {
                    settingsManager.localeString = deviceLocale.languageCode;
                  } else {
                    settingsManager.localeString = 'en';
                  }
                });
              }

              return savedLocale ?? deviceLocale;
            },
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              const AppLocalizationsDelegate(),
            ],
            supportedLocales: SUPPORTED_LOCALES.map((locale) => locale.locale).toList(),
            theme: settingsManager.appTheme,
            home: StartPage(),
          );
        },
      )
    );
  }
}
