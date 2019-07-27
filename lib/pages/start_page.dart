import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/pages/game_page.dart';
import 'package:flutter/material.dart';

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

  void _handleNewGameButtonPressed(BuildContext context) {
    PopupActionSheet(
      title: 'Start New Game',
      items: GAME_MODES.map((gameMode) => PopupActionSheetItem(
        leading: getIcon(gameMode),
        text: getString(gameMode),
        onTap: () => _startNewGame(gameMode, context)
      )).toList()
    ).show(context);
  }

  void _startNewGame(GameMode gameMode, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(gameMode),
        fullscreenDialog: true, // Prevents swipe back
      )
    );
  }

  void _handleHelpButtonPressed() {

  }

  void _handleStatsButtonTapped() {

  }

  void _handleSettingsButtonTapped() {

  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 20,
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
                      _buildButton('Continue Game', null),
                      _buildButton('New Game', () => _handleNewGameButtonPressed(context)),
                      _buildButton('Multiplayer', null),
                      _buildButton('Replays', null),
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
                    onPressed: _handleHelpButtonPressed,
                  ),
                  IconButton(
                    icon: Icon(Icons.assessment),
                    onPressed: _handleStatsButtonTapped,
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: _handleSettingsButtonTapped,
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
