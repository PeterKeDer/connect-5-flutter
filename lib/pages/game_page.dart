import 'package:connect_5/controllers/local_bot.dart';
import 'package:connect_5/models/min_max_bot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:connect_5/components/game_board.dart';
import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/controllers/local_two_player.dart';
import 'package:connect_5/models/game.dart';

class GamePage extends StatefulWidget {
  GamePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GamePageState createState() => _GamePageState();
}

enum GameMode {
  twoPlayers, blackBot, whiteBot
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  GameController gameController;

  @override
  void initState() {
    super.initState();
  
    _handleRestartGame(GameMode.twoPlayers);
  }

  void _handleRestartGame(GameMode mode) {
    GameController newController;

    switch (mode) {
      case GameMode.twoPlayers:
        newController = LocalTwoPlayerGameController(Game.createNew(15), this);
        break;
      case GameMode.blackBot:
        newController = LocalBotGameController(Game.createNew(15), MinMaxBot(), Side.black, this);
        break;
      case GameMode.whiteBot:
        newController = LocalBotGameController(Game.createNew(15), MinMaxBot(), Side.white, this);
        break;
    }

    setState(() {
      gameController = newController;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect 5'),
        actions: <Widget>[
          PopupMenuButton<GameMode>(
            child: Container(
              width: 60,
              height: 60,
              child: Icon(Icons.refresh),
            ),
            onSelected: _handleRestartGame,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: GameMode.twoPlayers,
                child: Text('Two Players'),
              ),
              PopupMenuItem(
                value: GameMode.blackBot,
                child: Text('Bot (Black)'),
              ),
              PopupMenuItem(
                value: GameMode.whiteBot,
                child: Text('Bot (White)'),
              ),
            ],
          ),
        ],
      ),
      body: ChangeNotifierProvider<GameController>.value(
        value: gameController,
        child: GameBoard(),
      )
    );
  }
}
