import 'package:connect_5/components/popup_action_sheet.dart';
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
 final GameMode gameMode;

  GamePage(this.gameMode);

  @override
  _GamePageState createState() => _GamePageState(gameMode);
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  static const double DEFAULT_SPACING = 20;

  final GameMode gameMode;
  GameController gameController;

  _GamePageState(this.gameMode);

  @override
  void initState() {
    super.initState();

    _handleRestartGame();
  }

  void _handleRestartGame() {
    GameController newController;

    switch (gameMode) {
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
  
  void _handleMenuButtonTapped() {
    PopupActionSheet(
      items: [
        PopupActionSheetItem(
          leading: const Icon(Icons.refresh),
          text: 'Restart Game',
          onTap: _handleRestartGame
        ),
        PopupActionSheetItem(
          leading: const Icon(Icons.close),
          text: 'Quit',
          onTap: () => Navigator.pop(context),
        )
      ]
    ).show(context);
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
                  handleMenuButtonTapped: _handleMenuButtonTapped,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
