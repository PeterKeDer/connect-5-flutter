import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/helpers/stats_manager.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


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

  Connect5App(this.settingsManager, this.gameStorageManger, this.statsManager);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameStorageManager>.value(value: gameStorageManger),
        ChangeNotifierProvider<SettingsManager>.value(value: settingsManager),
        ChangeNotifierProvider<StatsManager>.value(value: statsManager),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          title: 'Connect 5',
          theme: Provider.of<SettingsManager>(context).appTheme,
          home: StartPage(),
        ),
      )
    );
  }
}
