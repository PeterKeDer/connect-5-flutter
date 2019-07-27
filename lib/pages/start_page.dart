import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/pages/game_page.dart';
import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  Widget _buildButton(String title, VoidCallback onPressed) {
    return RaisedButton(
      child: Text(title),
      onPressed: onPressed,
    );
  }

  void _handleNewGameButtonPressed(BuildContext context) {
    PopupActionSheet(
      GAME_MODES.map((gameMode) => PopupActionSheetItem(
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

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Center(
              child: IntrinsicWidth(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildButton('Continue Game', null),
                    _buildButton('New Game', () => _handleNewGameButtonPressed(context)),
                    _buildButton('Multiplayer', null)
                  ],
                ),
              ),
            )
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Text('Connect 5', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
