import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameStatusBar extends StatelessWidget {
  static const double SPACING = 20;
  static const double BAR_HEIGHT = 80;
  static const double BORDER_RADIUS = 10;
  static const BACKGROUND_ALPHA = 180;
  static const ANIMATION_DURATION = Duration(milliseconds: 150);

  final VoidCallback handleMenuButtonTapped;

  GameStatusBar({this.handleMenuButtonTapped});

  Widget _buildMenuButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: handleMenuButtonTapped
    );
  }

  Widget _buildPieceIndicator(Color color) {
    final size = BAR_HEIGHT - SPACING;

    return AnimatedContainer(
      duration: ANIMATION_DURATION,
      padding: EdgeInsets.only(right: SPACING),
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2)
      ),
    );
  }

  Widget _buildStatusText(BuildContext context, GameController gameController) {
    String statusBarText;
    if (gameController.game.winner != null) {
      statusBarText = localize(context, gameController.game.winner.side == Side.black ? 'black_victory' : 'white_victory');
    } else if (gameController.game.isFull) {
      statusBarText = localize(context, 'tie');
    } else {
      statusBarText = localize(context, getDisplayString(gameController.gameMode));
    }

    return Text(
      statusBarText,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameController = Provider.of<GameController>(context);
    final theme = Provider.of<SettingsManager>(context).boardTheme;
    final pieceColor = gameController.game.currentSide == Side.black ? theme.blackPieceColor : theme.whitePieceColor;

    return Container(
      height: BAR_HEIGHT,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(BACKGROUND_ALPHA),
        borderRadius: BorderRadius.circular(BORDER_RADIUS),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SPACING, vertical: SPACING / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (!gameController.game.isFinished)
              _buildPieceIndicator(pieceColor),
            _buildStatusText(context, gameController),
            _buildMenuButton(context)
          ],
        ),
      ),
    );
  }
}
