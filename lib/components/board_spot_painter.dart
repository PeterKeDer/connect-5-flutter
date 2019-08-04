import 'package:connect_5/models/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BoardSpotPainter extends ChangeNotifier {
  // Constants
  static const ANIMATION_DURATION = Duration(milliseconds: 150);
  static const double PIECE_SIZE_RATIO = 0.8;
  static const double TRANSPARENT_PIECE_PROGRESS = 0.8;
  static const double TARGET_STROKE_WIDTH_RATIO = 0.1;
  static const double HIGHLIGHT_STROKE_WIDTH_RATIO = 0.1;

  final TickerProvider tickerProvider;

  BoardSpotPainter(this.tickerProvider);

  // Board piece

  double _pieceProgress = 0;
  Side _pieceSide;
  final _piecePaint = Paint();

  AnimationController _pieceController;
  Animation<double> _pieceAnimation;

  void addTransparentPieceAnimated(Side side) {
    _pieceSide = side;
    _animatePiece(TRANSPARENT_PIECE_PROGRESS);
  }

  void addPieceAnimated(Side side) {
    _pieceSide = side;
    _animatePiece(1);
  }

  void addPiece(Side side) {
    _pieceSide = side;
    _pieceProgress = 1;
    notifyListeners();
  }

  void removePieceAnimated() => _animatePiece(0);

  void _animatePiece(double progress) {
    _pieceController?.stop();

    _pieceController = AnimationController(duration: ANIMATION_DURATION, vsync: tickerProvider);
    _pieceAnimation = Tween<double>(begin: _pieceProgress, end: progress).animate(_pieceController)
      ..addListener(() {
        _pieceProgress = _pieceAnimation.value;
        notifyListeners();
      });
    _pieceController.forward();
  }

  // Target

  double _targetProgress = 0;
  
  final _targetPaint = Paint()
    ..color = Colors.red.withAlpha(200)
    ..style = PaintingStyle.stroke;

  AnimationController _targetController;
  Animation<double> _targetAnimation;

  void addTargetAnimated() => _animateTarget(1);
  void removeTargetAnimated() => _animateTarget(0);

  void _animateTarget(double progress) {
    _targetController?.stop();

    _targetController = AnimationController(duration: ANIMATION_DURATION, vsync: tickerProvider);
    _targetAnimation = Tween<double>(begin: _targetProgress, end: progress).animate(_targetController)
      ..addListener(() {
        _targetProgress = _targetAnimation.value;
        notifyListeners();
      });
    _targetController.forward();
  }

  // Highlight

  double _highlightProgress = 0;

  final Paint _highlightPaint = Paint()
    ..color = Colors.orange
    ..style = PaintingStyle.stroke;

  AnimationController _highlightController;
  Animation<double> _highlightAnimation;

  bool get isHighlighted => _highlightProgress != 0;

  void addHighlightAnimated() => _animateHighlight(1);
  void removeHighlightAnimated() => _animateHighlight(0);

  void _animateHighlight(double progress) {
    _highlightController?.stop();

    _highlightController = AnimationController(duration: ANIMATION_DURATION, vsync: tickerProvider);
    _highlightAnimation = Tween<double>(begin: _highlightProgress, end: progress).animate(_highlightController)
      ..addListener(() {
        _highlightProgress = _highlightAnimation.value;
        notifyListeners();
      });
    _highlightController.forward();
  }

  int _getAlpha(double progress) => (progress * 255).floor();

  /// Paint the spot on the board given offset and box size
  void paint(Canvas canvas, Offset center, double boxSize) {
    if (_pieceProgress != 0) {
      // Draw piece
      final color = _pieceSide == Side.black ? Colors.black : Colors.white;
      _piecePaint.color = color.withAlpha(_getAlpha(_pieceProgress));
      canvas.drawCircle(center, PIECE_SIZE_RATIO / 2 * boxSize * _pieceProgress, _piecePaint);
    }

    if (_targetProgress != 0) {
      // Draw target
      final size = boxSize * PIECE_SIZE_RATIO * _targetProgress;

      _targetPaint.strokeWidth = TARGET_STROKE_WIDTH_RATIO * boxSize;
      _targetPaint.color = Colors.red.withAlpha(_getAlpha(_targetProgress));

      final left = center.dx - size / 2;
      final right = center.dx + size / 2;
      final up = center.dy - size / 2;
      final down = center.dy + size / 2;
      final edgeLength = size / 4;

      final path = Path();

      path.moveTo(left, up + edgeLength);
      path.lineTo(left, up);
      path.lineTo(left + edgeLength, up);

      path.moveTo(right - edgeLength, up);
      path.lineTo(right, up);
      path.lineTo(right, up + edgeLength);

      path.moveTo(right, down - edgeLength);
      path.lineTo(right, down);
      path.lineTo(right - edgeLength, down);

      path.moveTo(left + edgeLength, down);
      path.lineTo(left, down);
      path.lineTo(left, down - edgeLength);
      
      canvas.drawPath(path, _targetPaint);
    }

    if (_highlightProgress != 0) {
      // Draw highlight
      _highlightPaint.strokeWidth = HIGHLIGHT_STROKE_WIDTH_RATIO * boxSize * _highlightProgress;
      _highlightPaint.color = Colors.orange.withAlpha(_getAlpha(_highlightProgress));
      canvas.drawCircle(center, PIECE_SIZE_RATIO / 2 * boxSize, _highlightPaint);
    }
  }
}
