import 'package:connect_5/controllers/game_controller.dart';
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
  // TODO: move into global ui constants file
  static const double DEFAULT_SPACING = 20;
  static const double BAR_HEIGHT = 80;
  static const double BORDER_RADIUS = 10;
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
    final size = BAR_HEIGHT - DEFAULT_SPACING;

    return Container(
      padding: EdgeInsets.only(right: DEFAULT_SPACING),
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
      statusBarText = gameController.game.winner.side == Side.black ? 'Black Victory!' : 'White Victory!';
    } else if (gameController.game.isFull) {
      statusBarText = 'Tie!';
    } else {
      statusBarText = getString(gameController.gameMode);
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
      final color = _prevSide == Side.black ? Colors.black : Colors.white;

      _pieceColorAnimationController.reset();
      _pieceColorAnimation = ColorTween(begin: _currentColor, end: color).animate(_pieceColorAnimationController);
      _pieceColorAnimation.addListener(() {
        print(_pieceColorAnimation.value);
        setState(() {
          _currentColor = _pieceColorAnimation.value;
        });
      });
      _pieceColorAnimationController.forward();
    }

    return Container(
      height: BAR_HEIGHT,
      decoration: BoxDecoration(
        color: Colors.lightBlue.withAlpha(180),
        borderRadius: BorderRadius.circular(BORDER_RADIUS),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DEFAULT_SPACING, vertical: DEFAULT_SPACING / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // TODO: maybe animate this
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
