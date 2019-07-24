import 'package:connect_5/pages/game_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(Connect5App());

class Connect5App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect 5',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamePage(),
    );
  }
}
