import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/components/status_bar.dart';
import 'package:connect_5/controllers/local_bot.dart';
import 'package:connect_5/controllers/replay_controller.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/models/min_max_bot.dart';
import 'package:connect_5/models/storable_games.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:connect_5/components/game_board.dart';
import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/controllers/local_two_player.dart';
import 'package:connect_5/models/game.dart';

class GamePage extends StatefulWidget {
  final GameMode gameMode;
  final Game game;
  final bool isReplay;

  GamePage(this.gameMode, {this.game}) : isReplay = false;

  GamePage.replay(this.gameMode, this.game) : isReplay = true;

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

    // Future delayed to be able to use context
    Future.delayed(Duration.zero).then((_) {
      _startGame(widget.game ?? _createNewGame());
    });
  }

  void _startGame(Game game) {
    final settings = Provider.of<SettingsManager>(context);

    GameController newController;

    if (widget.isReplay) {
      newController = ReplayGameController(widget.game, gameMode, settings, this);
    } else {
      switch (gameMode) {
      case GameMode.twoPlayers:
        newController = LocalTwoPlayerGameController(game, settings, this);
        break;
      case GameMode.blackBot:
        newController = LocalBotGameController(game, MinMaxBot(), Side.black, settings, this);
        break;
      case GameMode.whiteBot:
        newController = LocalBotGameController(game, MinMaxBot(), Side.white, settings, this);
        break;
      }
    }

    newController.onGameEvent(_saveGame);

    setState(() {
      gameController = newController;
    });
  }

  Game _createNewGame() {
    final boardSize = Provider.of<SettingsManager>(context).boardSize;
    return Game.createNew(boardSize);
  }

  void _handleRestartGame() {
    if (!widget.isReplay) {
      Provider.of<GameStorageManager>(context).clearLastGame();
      _startGame(_createNewGame());
    } else {
      _startGame(widget.game);
    }
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
          onTap: () {
            Navigator.pop(context);
          },
        )
      ]
    ).show(context);
  }

  void _saveGame() {
    if (widget.isReplay) {
      return;
    }

    final game = gameController.game;
    final storageManager = Provider.of<GameStorageManager>(context);

    if (!game.isFinished && game.steps.isNotEmpty) {
      // Game is not finished and not empty, save game
      storageManager.saveLastGame(GameData.fromGame(game, gameMode));
    } else {
      // Clear saved game
      storageManager.clearLastGame();
    }

    if (game.isFinished) {
      // Save to replays
      final date = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(date);
      storageManager.saveReplay(ReplayData.fromGame(game, gameMode, formattedDate, game.winner?.side));
    }
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
