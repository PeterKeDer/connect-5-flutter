import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


void main() async {
  final settingsManager = SettingsManager();
  final gameStorageManager = GameStorageManager();

  await gameStorageManager.readGamesAsync();
  await settingsManager.initAsync();

  runApp(Connect5App(settingsManager, gameStorageManager));
}

class Connect5App extends StatelessWidget {
  final SettingsManager settingsManager;
  final GameStorageManager gameStorageManger;

  Connect5App(this.settingsManager, this.gameStorageManger);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameStorageManager>.value(value: gameStorageManger),
        ChangeNotifierProvider<SettingsManager>.value(value: settingsManager),
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
