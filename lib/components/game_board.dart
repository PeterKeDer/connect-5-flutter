
import 'package:flutter/material.dart';
import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/models/game.dart';
import 'package:provider/provider.dart';
import 'board_painter.dart';

class GameBoard extends StatefulWidget {
  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  static const double MAX_ZOOM = 4;
  static const double MIN_ZOOM = 1;
  static const double DEFAULT_BOARD_SIZE = 300; // TODO: adjust with screen size

  static const ANIMATION_DURATION = Duration(milliseconds: 150);
  
  GameController get _controller => Provider.of<GameController>(context);

  /// Previous offset from center of the board when the scale started
  Offset _initialOffset;

  /// Initial focal point of the scale
  Offset _initialFocalPoint;

  /// Offset of board from center
  Offset _offset = Offset.zero;
  
  /// Zoom when scale started
  double _initialZoom;

  /// Current zoom of the board
  double _zoom = 1;

  // Board zoom animations
  Animation<double> _boardZoomAnimation;
  AnimationController _boardZoomAnimationController;

  @override
  void initState() {
    super.initState();

    _boardZoomAnimationController = AnimationController(duration: ANIMATION_DURATION, vsync: this);
  }

  @override
  void deactivate() {
    super.deactivate();

    _controller.dispose();
  }

  void _handleScaleStart(ScaleStartDetails scale) {
    setState(() {
      _initialZoom = _zoom;
      _initialFocalPoint = scale.focalPoint;
      _initialOffset = _offset;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails scale) {
    _controller.moveBoard();

    setState(() {
      if (scale.scale == 1) {
        // Single finger zoom, only adjust center (reset zoom)
        _initialZoom = _zoom;
      } else {
        // Scaling with two fingers, stop animation
        _boardZoomAnimationController.stop();
        
        // Adjust zoom based on scale
        _zoom = _initialZoom * scale.scale;
      }

      // Distance between current focal point and center 
      // = scale * distance between initial center and initial focal point
      // _center = scale.focalPoint - (_initialFocalPoint - _initialCenter) * scale.scale;

      // TODO: improve this maybe
      _offset = scale.focalPoint - _initialFocalPoint + _initialOffset;
    });
  }

  void _handleScaleEnd(ScaleEndDetails scale) {
    // Animate zoom if bigger than max / smaller than min
    if (_zoom > MAX_ZOOM) {
      _animateZoom(MAX_ZOOM);
    } else if (_zoom < MIN_ZOOM) {
      _animateZoom(MIN_ZOOM);
    }
  }

  void _animateZoom(double newZoom) {
    // Reset ongoing animation, if needed
    _boardZoomAnimation?.removeListener(_handleZoomAnimate);
    _boardZoomAnimationController.reset();

    // Start new zoom animation
    _boardZoomAnimation = Tween(begin: _zoom, end: newZoom)
      .animate(_boardZoomAnimationController)
      ..addListener(_handleZoomAnimate);

    _boardZoomAnimationController.forward();
  }

  void _handleZoomAnimate() {
    setState(() => _zoom = _boardZoomAnimation.value);
  }

  void _handleTapUp(TapUpDetails tap) {
    final point = _getPoint(tap.localPosition);
    if (point != null) {
      _controller.tap(point);
    }
  }

  /// Get the point on board for position, if valid. Otherwise returns null
  Point _getPoint(Offset position) {
    final boxSize = DEFAULT_BOARD_SIZE / (_controller.game.board.size + 1);
    final x = (position.dx / boxSize).round() - 1; // -1 to compensate for padding
    final y = (position.dy / boxSize).round() - 1;

    if (0 <= x && x < _controller.game.board.size && 0 <= y && y < _controller.game.board.size) {
      return Point(x, y);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      onTapUp: _handleTapUp,
      child: Container(
        color: Colors.white, // needed for gesture to activate on background
        child: Center(
          child: Transform(
            transform: Matrix4.identity()
              ..scale(_zoom)
              ..translate(_offset.dx / _zoom, _offset.dy / _zoom)
              // Position board center
              ..translate((1 / _zoom - 1) * DEFAULT_BOARD_SIZE / 2, (1 / _zoom - 1) * DEFAULT_BOARD_SIZE / 2),
            child: GestureDetector(
              onTapUp: _handleTapUp,
              child: Container(
                height: DEFAULT_BOARD_SIZE,
                width: DEFAULT_BOARD_SIZE,
                child: CustomPaint(
                  painter: BoardPainter(
                    game: _controller.game,
                    spotPainters: _controller.spotPainters
                  ),
                ),
              )
            ),
          ),
        ),
      ),
    );
  }
}
