import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameStatusBar extends StatefulWidget {
  final GameController gameController;
  final VoidCallback handleMenuButtonTapped;

  GameStatusBar({this.gameController, this.handleMenuButtonTapped});

  @override
  _GameStatusBarState createState() => _GameStatusBarState();
}

class _GameStatusBarState extends State<GameStatusBar> with SingleTickerProviderStateMixin {
  static const double SPACING = 20;
  static const double BAR_HEIGHT = 80;
  static const double BORDER_RADIUS = 10;
  static const BACKGROUND_ALPHA = 180;
  static const ANIMATION_DURATION = Duration(milliseconds: 150);

  AnimationController _pieceColorAnimationController;
  Animation<Color> _pieceColorAnimation;

  Color _currentColor;
  Side _prevSide;

  @override
  void initState() {
    super.initState();

    _pieceColorAnimationController = AnimationController(duration: ANIMATION_DURATION, vsync: this); 
  }

  @override
  void dispose() {
    _pieceColorAnimationController.dispose();

    super.dispose();
  }

  Widget _buildMenuButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: widget.handleMenuButtonTapped
    );
  }

  Widget _buildPieceIndicator(Side side) {
    final size = BAR_HEIGHT - SPACING;

    return Container(
      padding: EdgeInsets.only(right: SPACING),
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: _currentColor,
        borderRadius: BorderRadius.circular(size / 2)
      ),
    );
  }
  
  Widget _buildStatusText(GameController gameController) {
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

    if (_prevSide != gameController.game.currentSide) {
      _prevSide = gameController.game.currentSide;
      final boardTheme = Provider.of<SettingsManager>(context).boardTheme;
      final color = _prevSide == Side.black ? boardTheme.blackPieceColor : boardTheme.whitePieceColor;

      _pieceColorAnimationController.reset();
      _pieceColorAnimation = ColorTween(begin: _currentColor, end: color).animate(_pieceColorAnimationController);
      _pieceColorAnimation.addListener(() {
        setState(() {
          _currentColor = _pieceColorAnimation.value;
        });
      });
      _pieceColorAnimationController.forward();
    }

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
              _buildPieceIndicator(gameController.game.currentSide),
            _buildStatusText(gameController),
            _buildMenuButton(context)
          ],
        ),
      ),
    );
  }
}
