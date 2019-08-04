import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


void main() => runApp(Connect5App());

class Connect5App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameStorageManager>.value(value: GameStorageManager()),
        ChangeNotifierProvider<SettingsManager>.value(value: SettingsManager()),
      ],
      child: MaterialApp(
        title: 'Connect 5',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StartPage(),
      )
    );
  }
}
