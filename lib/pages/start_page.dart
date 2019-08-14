import 'package:connect_5/components/loading_dialog.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/pages/game_page.dart';
import 'package:connect_5/pages/help_page.dart';
import 'package:connect_5/pages/multiplayer/rooms_page.dart';
import 'package:connect_5/pages/replays_page.dart';
import 'package:connect_5/pages/settings_page.dart';
import 'package:connect_5/pages/stats_page.dart';
import 'package:connect_5/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartPage extends StatelessWidget {
  Widget _buildButton(BuildContext context, String title, HandlerFunction<BuildContext> onPressed) {
    return RaisedButton(
      child: Text(
        localize(context, title),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      onPressed: onPressed == null ? null : () => onPressed(context),
    );
  }

  void _handleContinueGameButtonPressed(BuildContext context) {
    final gameData = Provider.of<GameStorageManager>(context).games.lastGame;
    _startGame(context, gameData.gameMode, game: gameData.game);
  }

  void _handleNewGameButtonPressed(BuildContext context) {
    PopupActionSheet(
      title: localize(context, 'start_new_game'),
      items: LOCAL_GAME_MODES.map((gameMode) => PopupActionSheetItem(
        leading: getIcon(gameMode, color: Theme.of(context).textTheme.caption.color),
        text: localize(context, getDisplayString(gameMode)),
        onTap: () => _startGame(context, gameMode)
      )).toList()
    ).show(context);
  }

  /// Start a game with game mode, and optionally game (null for create new game)
  void _startGame(BuildContext context, GameMode gameMode, {Game game}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(gameMode, game: game),
        fullscreenDialog: true, // Prevents swipe back
      )
    );
  }

  void _handleMultiplayerButtonPressed(BuildContext context) async {
    showLoadingDialog(context);

    final rooms = await Provider.of<MultiplayerManager>(context).getRooms();
    Navigator.pop(context);

    if (rooms != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiplayerRoomsPage(),
        )
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localize(context, 'connection_failed')),
          content: Text(localize(context, 'connection_failed_message')),
          actions: <Widget>[
            FlatButton(
              child: Text(localize(context, 'ok')),
              textColor: Theme.of(context).colorScheme.primary,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        )
      );
    }
  }

  void _handleReplaysButtonPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReplaysPage()
      )
    );
  }

  void _handleHelpButtonPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HelpPage()
      )
    );
  }

  void _handleStatsButtonTapped(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatsPage()
      )
    );
  }

  void _handleSettingsButtonTapped(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final storageManger = Provider.of<GameStorageManager>(context);

    return Material(
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Text(
                localize(context, 'connect_5'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildButton(context, 'continue_game', storageManger.games?.lastGame == null
                        ? null
                        : _handleContinueGameButtonPressed
                      ),
                      _buildButton(context, 'new_game', _handleNewGameButtonPressed),
                      _buildButton(context, 'multiplayer', _handleMultiplayerButtonPressed),
                      _buildButton(context, 'replays', _handleReplaysButtonPressed),
                    ],
                  ),
                ),
              )
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.help),
                    onPressed: () => _handleHelpButtonPressed(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.assessment),
                    onPressed: () => _handleStatsButtonTapped(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () => _handleSettingsButtonTapped(context),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
