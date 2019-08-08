
import 'dart:math' as math;

import 'package:connect_5/helpers/settings_manager.dart';
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

  static const ANIMATION_DURATION = Duration(milliseconds: 150);

  // Used to get center of the container, to improve zooming / dragging experience
  final containerGlobalKey = GlobalKey();

  double get defaultBoardSize {
    final size = MediaQuery.of(context).size;
    return math.min(size.width, size.height) * 0.8;
  }
  
  GameController get _controller => Provider.of<GameController>(context);

  /// Previous offset from center of the board when the scale started
  Offset _initialOffset;

  /// Initial focal point of the scale
  Offset _initialFocalPoint;

  /// Offset of board from center
  Offset _offset = Offset.zero;
  
  /// The center of the container of the board
  Offset _center;

  /// The initial center of board, when scale begins
  Offset _initialBoardCenter;

  /// The last focal point where at least two fingers scale
  Offset _lastScaleFocalPoint;

  /// Zoom when scale started
  double _initialZoom;

  /// Current zoom of the board
  double _zoom = 1;

  // Zoom animations
  Animation<double> _zoomAnimation;
  AnimationController _zoomAnimationController;

  // Offset animations
  Animation<Offset> _offsetAnimation;
  AnimationController _offsetAnimationController;

  @override
  void initState() {
    super.initState();

    _zoomAnimationController = AnimationController(duration: ANIMATION_DURATION, vsync: this);
    _offsetAnimationController = AnimationController(duration: ANIMATION_DURATION, vsync: this);
  }

  void _handleScaleStart(ScaleStartDetails scale) {
    setState(() {
      _initialZoom = _zoom;
      _initialFocalPoint = scale.focalPoint;
      _initialOffset = _offset;

      final box = containerGlobalKey.currentContext.findRenderObject() as RenderBox;
      _center = box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
      _initialBoardCenter = _center + _initialOffset;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails scale) {
    _controller.moveBoard();

    setState(() {
      // Moving board, stop animations
      _offsetAnimationController.stop();
      _zoomAnimationController.stop();

      if (scale.scale == 1) {
        // Single finger zoom, only adjust center (reset zoom)
        _initialZoom = _zoom;
      } else {
        // Adjust zoom based on scale
        _zoom = _initialZoom * scale.scale;

        _lastScaleFocalPoint = scale.focalPoint;
      }

      // Distance between current focal point and center 
      // = scale * distance between initial center and initial focal point
      _offset = scale.focalPoint - (_initialFocalPoint - _initialBoardCenter) * scale.scale - _center;
    });
  }

  void _handleScaleEnd(ScaleEndDetails scale) {
    // Animate zoom if bigger than max / smaller than min
    double newZoom = _zoom;
    if (_zoom > MAX_ZOOM) {
      newZoom = MAX_ZOOM;
      _animateZoom(MAX_ZOOM);
    } else if (_zoom < MIN_ZOOM) {
      newZoom = MIN_ZOOM;
      _animateZoom(MIN_ZOOM);
    }

    // The distance between focal point and board center scales to new zoom
    final boardCenter = _offset + _center;
    final newBoardCenter = (boardCenter - _lastScaleFocalPoint) / _zoom * newZoom + _lastScaleFocalPoint;
    final newOffset = newBoardCenter - _center;

    // Change offset if board is too far from center
    final halfBoardSize = defaultBoardSize * newZoom / 2;
    final dx = math.max(-halfBoardSize, math.min(halfBoardSize, newOffset.dx));
    final dy = math.max(-halfBoardSize, math.min(halfBoardSize, newOffset.dy));

    if (dx != _offset.dx || dy != _offset.dy) {
      _animateOffset(Offset(dx, dy));
    }
  }

  void _animateZoom(double newZoom) {
    // Reset ongoing animation, if needed
    _zoomAnimation?.removeListener(_handleZoomAnimate);
    _zoomAnimationController.reset();

    // Start new zoom animation
    _zoomAnimation = Tween(begin: _zoom, end: newZoom)
      .animate(_zoomAnimationController)
      ..addListener(_handleZoomAnimate);

    _zoomAnimationController.forward();
  }

  void _handleZoomAnimate() {
    setState(() => _zoom = _zoomAnimation.value);
  }

  void _animateOffset(Offset newOffset) {
    // Remove ongoing animation, if needed
    _offsetAnimation?.removeListener(_handleOffsetAnimate);
    _offsetAnimationController.reset();

    // Start new offset animation
    _offsetAnimation = Tween(begin: _offset, end: newOffset)
      .animate(_offsetAnimationController)
      ..addListener(_handleOffsetAnimate);
    
    _offsetAnimationController.forward();
  }

  void _handleOffsetAnimate() {
    setState(() => _offset = _offsetAnimation.value);
  }

  void _handleTapUp(TapUpDetails tap) {
    final point = _getPoint(tap.localPosition);
    if (point != null) {
      _controller.tap(point);
    }
  }

  /// Get the point on board for position, if valid. Otherwise returns null
  Point _getPoint(Offset position) {
    final boxSize = defaultBoardSize / (_controller.game.board.size + 1);
    final x = (position.dx / boxSize).round() - 1; // -1 to compensate for padding
    final y = (position.dy / boxSize).round() - 1;

    if (0 <= x && x < _controller.game.board.size && 0 <= y && y < _controller.game.board.size) {
      return Point(x, y);
    }

    return null;
  }

  Matrix4 get _boardTransform => Matrix4.identity()
    ..scale(_zoom)
    ..translate(_offset.dx / _zoom, _offset.dy / _zoom)
    // Position board center
    ..translate((1 / _zoom - 1) * defaultBoardSize / 2, (1 / _zoom - 1) * defaultBoardSize / 2);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      onTapUp: _handleTapUp,
      child: Container(
        key: containerGlobalKey,
        color: Colors.transparent, // needed for gesture to activate on background
        child: Center(
          child: Transform(
            transform: _boardTransform,
            child: GestureDetector(
              onTapUp: _handleTapUp,
              child: Container(
                height: defaultBoardSize,
                width: defaultBoardSize,
                child: CustomPaint(
                  painter: BoardPainter(
                    boardSize: _controller.game.board.size,
                    spotPainters: _controller.spotPainters,
                    boardTheme: Provider.of<SettingsManager>(context).boardTheme,
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
