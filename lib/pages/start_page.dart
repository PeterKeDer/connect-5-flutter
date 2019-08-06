import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/pages/game_page.dart';
import 'package:connect_5/pages/help_page.dart';
import 'package:connect_5/pages/replays_page.dart';
import 'package:connect_5/pages/settings_page.dart';
import 'package:connect_5/pages/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartPage extends StatelessWidget {
  Widget _buildButton(String title, VoidCallback onPressed) {
    return RaisedButton(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      onPressed: onPressed,
    );
  }

  void _handleContinueGameButtonPressed(BuildContext context) {
    final gameData = Provider.of<GameStorageManager>(context).games.lastGame;
    _startGame(context, gameData.gameMode, game: gameData.game);
  }

  void _handleNewGameButtonPressed(BuildContext context) {
    PopupActionSheet(
      title: 'Start New Game',
      items: LOCAL_GAME_MODES.map((gameMode) => PopupActionSheetItem(
        leading: getIcon(gameMode, color: Theme.of(context).textTheme.caption.color),
        text: getString(gameMode),
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
                'Connect 5',
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
                      _buildButton('Continue Game', storageManger.games?.lastGame == null
                        ? null
                        : () => _handleContinueGameButtonPressed(context)
                      ),
                      _buildButton('New Game', () => _handleNewGameButtonPressed(context)),
                      _buildButton('Replays', () => _handleReplaysButtonPressed(context)),
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
