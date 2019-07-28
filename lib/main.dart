import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(Connect5App());

class Connect5App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameStorageManager>.value(
      value: GameStorageManager(),
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
