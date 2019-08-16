import 'package:connect_5/controllers/multiplayer_controller.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/components/status_bar.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/helpers/stats_manager.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/models/storable_games.dart';
import 'package:connect_5/pages/multiplayer/room_info_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:connect_5/components/game_board.dart';
import 'package:connect_5/controllers/game_controller.dart';

class GameEventMessage {
  final String text;

  GameEventMessage(this.text);
}

class MultiplayerGamePage extends StatefulWidget {
  @override
  _MultiplayerGamePageState createState() => _MultiplayerGamePageState();
}

// TODO: check for spectator support
class _MultiplayerGamePageState extends State<MultiplayerGamePage> with TickerProviderStateMixin {
  static const double DEFAULT_SPACING = 20;

  MultiplayerGameController gameController;

  Game get game => gameController.game;

  MultiplayerManager get multiplayerManager => Provider.of(context);

  final _messageListKey = GlobalKey<AnimatedListState>();

  List<GameEventMessage> messages = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      setState(() {
        gameController = MultiplayerGameController(
          Provider.of<MultiplayerManager>(context),
          Provider.of<SettingsManager>(context),
          this,
        );
        gameController.onGameEvent(_saveGame);

        // Refresh when game updates
        gameController.addListener(() => setState(() {}));
      });
    });
  }

  @override
  void dispose() {
    gameController.dispose();
    super.dispose();
  }

  Widget _buildMessageBlock(Animation<double> animation, String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: FadeTransition(
      opacity: animation,
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).colorScheme.primary.withAlpha(GameStatusBar.BACKGROUND_ALPHA),
          ),
          child: Text(message),
        ),
      ),
    ),
  );

  /// Displays a message that disappears after a short duration
  void _displayMessage(GameEventMessage message) {
    messages.insert(0, message);
    _messageListKey.currentState.insertItem(0);

    Future.delayed(const Duration(seconds: 3), () {
      if (this.mounted) {
        final index = messages.indexOf(message);
        final text = messages.removeAt(index).text;
        _messageListKey.currentState.removeItem(index, (context, animation) => _buildMessageBlock(animation, text));
      }
    });
  }

  void _handleMenuButtonTapped() {
    PopupActionSheet(
      items: [
        if (multiplayerManager.canResetGame)
          PopupActionSheetItem(
            leading: const Icon(Icons.refresh),
            text: localize(context, 'restart'),
            onTap: _handleRestartButtonTapped,
          ),
        PopupActionSheetItem(
          leading: const Icon(Icons.info_outline),
          text: localize(context, 'room_info'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiplayerRoomInfoPage(),
              )
            );
          }
        ),
        PopupActionSheetItem(
          leading: const Icon(Icons.close),
          text: localize(context, 'quit'),
          onTap: () {
            Provider.of<MultiplayerManager>(context).disconnect();
            Navigator.of(context)..pop()..pop();
          },
        )
      ]
    ).show(context);
  }

  void _saveGame() {
    if (game.isFinished) {
      // TODO: add correct game modes
      final gameMode = GameMode.twoPlayers;

      // Save to replays
      final date = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
      Provider.of<GameStorageManager>(context).saveReplay(ReplayData.fromGame(game, gameMode, date, game.winner?.side));
      Provider.of<StatsManager>(context).recordGame(gameMode, game);
    }
  }

  void _handleRestartButtonTapped() {
    if (multiplayerManager.canResetGame) {
      multiplayerManager.resetGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (gameController == null) {
      return Container();
    }

    return ChangeNotifierProvider<GameController>.value(
      value: gameController,
      child: Scaffold(
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
              Positioned(
                top: GameStatusBar.BAR_HEIGHT + DEFAULT_SPACING + 3,
                left: DEFAULT_SPACING,
                right: DEFAULT_SPACING,
                child: AnimatedList(
                  key: _messageListKey,
                  initialItemCount: messages.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index, animation) {
                    return _buildMessageBlock(animation, messages[index].text);
                  },
                ),
              ),
              if (multiplayerManager.canResetGame)
                Positioned(
                  bottom: DEFAULT_SPACING,
                  left: DEFAULT_SPACING,
                  right: DEFAULT_SPACING,
                  child: Center(
                    child: RaisedButton.icon(
                      icon: Icon(Icons.refresh),
                      label: Text(localize(context, 'restart')),
                      onPressed: _handleRestartButtonTapped,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
