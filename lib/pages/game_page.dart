import 'package:connect_5/components/status_bar.dart';
import 'package:connect_5/controllers/local_bot.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/models/min_max_bot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_5/components/game_board.dart';
import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/controllers/local_two_player.dart';
import 'package:connect_5/models/game.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  static const double DEFAULT_SPACING = 20;

  GameMode gameMode;
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
      gameMode = mode;
      gameController = newController;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameController>.value(
      value: gameController,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: GameBoard()
              ),
              Positioned(
                top: DEFAULT_SPACING,
                left: DEFAULT_SPACING,
                right: DEFAULT_SPACING,
                child: GameStatusBar(
                  handleRestartGame: _handleRestartGame,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
