import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:connect_5/components/game_board.dart';
import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/models/game.dart';

class GamePage extends StatefulWidget {
  GamePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  GameController gameController;

  @override
  void initState() {
    super.initState();

    gameController = LocalTwoPlayerGameController(Game.createNew(15), this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect 5'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {
              gameController = LocalTwoPlayerGameController(Game.createNew(15), this);
            }),
          )
        ],
      ),
      body: ChangeNotifierProvider<GameController>.value(
        value: gameController,
        child: GameBoard(),
      )
    );
  }
}
