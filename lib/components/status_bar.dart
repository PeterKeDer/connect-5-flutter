import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef void GameModeHandler(GameMode gameMode);

class GameStatusBar extends StatelessWidget {
  // TODO: move into global ui constants file
  static const double DEFAULT_SPACING = 20;
  static const double BAR_HEIGHT = 80;

  final GameMode gameMode;
  final GameModeHandler handleRestartGame;

  GameStatusBar({this.gameMode, this.handleRestartGame});

  Widget _buildPopupMenuButton() {
    return PopupMenuButton<GameMode>(
      child: Container(
        width: 40,
        height: 40,
        child: Icon(Icons.refresh),
      ),
      onSelected: handleRestartGame,
      itemBuilder: (_) => GAME_MODES.map((mode) => PopupMenuItem<GameMode>(
        value: mode,
        child: Text(getString(mode)),
      )).toList()
    );
  }

  Widget _buildPieceIndicator(Side side) =>
    Container(
      padding: EdgeInsets.only(right: DEFAULT_SPACING),
      height: BAR_HEIGHT - DEFAULT_SPACING,
      width: BAR_HEIGHT - DEFAULT_SPACING,
      decoration: BoxDecoration(
        color: side == Side.black ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular((BAR_HEIGHT - DEFAULT_SPACING) / 2)
      ),
    );

  @override
  Widget build(BuildContext context) {
    final gameController = Provider.of<GameController>(context);

    String statusBarText;
    if (gameController.game.winner != null) {
      statusBarText = gameController.game.winner.side == Side.black ? 'Black Victory!' : 'White Victory!';
    } else if (gameController.game.isFull) {
      statusBarText = 'Tie!';
    } else {
      statusBarText = getString(gameMode);
    }

    return Container(
      height: BAR_HEIGHT,
      decoration: BoxDecoration(
        color: Colors.lightBlue.withAlpha(150),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DEFAULT_SPACING, vertical: DEFAULT_SPACING / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // TODO: maybe animate this
            if (!gameController.game.isFinished)
              _buildPieceIndicator(gameController.game.currentSide),
            Text(
              statusBarText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              )
            ),
            _buildPopupMenuButton()
          ],
        ),
      ),
    );
  }
}
