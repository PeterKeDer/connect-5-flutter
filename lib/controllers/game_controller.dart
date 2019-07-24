import 'package:flutter/material.dart';
import 'package:connect_5/components/board_spot_painter.dart';
import 'package:connect_5/models/game.dart';

abstract class GameController extends ChangeNotifier {
  final TickerProvider tickerProvider;

  Game get game;
  List<List<BoardSpotPainter>> spotPainters;

  GameController(this.tickerProvider);

  // Handle events
  void tap(Point point);
  void undo();
  void moveBoard();
}

mixin BoardSpotPaintersMixin on GameController {
  bool isDoubleTapConfirmationEnabled = true; 

  Point _sp;
  Point get _selectedPoint => _sp;
  set _selectedPoint(Point point) {
    if (_sp != null) {
      _removePiece(_sp);
      _removeTarget(_sp);
    }
    _sp = point;
    if (_sp != null) {
      _addTransparentPiece(_sp, game.currentSide);
      _addTarget(_sp);
    }
  }

  void _initBoardSpotPainters() {
    spotPainters = List.generate(game.board.size, (_) =>
      List.generate(game.board.size, (_) =>
        BoardSpotPainter(tickerProvider)
          ..addListener(notifyListeners)
      )
    );

    for (int x=0; x<game.board.size; x++) {
      for (int y=0; y<game.board.size; y++) {
        final point = Point(x, y);
        final spot = game.board.getSpot(point);
        if (spot != BoardSpot.empty) {
          _addPiece(point, spot == BoardSpot.black ? Side.black : Side.white);
        }
      }
    }
  }

  void _addPiece(Point point, Side side) {
    spotPainters[point.x][point.y].addPieceAnimated(side);
  }

  void _addTransparentPiece(Point point, Side side) {
    spotPainters[point.x][point.y].addTransparentPieceAnimated(side);
  }

  void _removePiece(Point point) {
    spotPainters[point.x][point.y].removePieceAnimated();
  }

  /// Returns false if needed to tap again on the same spot to proceed
  bool _checkDoubleTapConfirmation(Point point) {
    if (!isDoubleTapConfirmationEnabled) {
      return true;
    }

    if (game.board.getSpot(point) != BoardSpot.empty) {
      _selectedPoint = null;
      return false;
    }

    if (point == _selectedPoint) {
      _selectedPoint = null;
      return true;

    } else {
      _selectedPoint = point;
      return false;
    }
  }

  void _addTarget(Point point) {
    spotPainters[point.x][point.y].addTargetAnimated();
  }

  void _removeTarget(Point point) {
    spotPainters[point.x][point.y].removeTargetAnimated();
  }

  void _highlightPoints(List<Point> points) {
    for (final point in points) {
      spotPainters[point.x][point.y].addHighlightAnimated();
    }
  }

  void _removeHighlights() {
    for (final row in spotPainters) {
      for (final painter in row) {
        if (painter.isHighlighted) {
          painter.removeHighlightAnimated();
        }
      }
    }
  }
}

class LocalTwoPlayerGameController extends GameController with BoardSpotPaintersMixin {
  Game game;

  LocalTwoPlayerGameController(this.game, TickerProvider tickerProvider) : super(tickerProvider) {
    _initBoardSpotPainters();
  }

  @override
  void tap(Point point) {
    if (game.isFinished) {
      return;
    }

    if (!_checkDoubleTapConfirmation(point)) {
      notifyListeners();
      return;
    }

    try {
      final prevSide = game.currentSide;
      game.addStep(point);
      _addPiece(point, prevSide);
      
      _removeHighlights();
      _highlightPoints([point]);
      
      final winner = game.winner;
      if (winner != null) {
        _highlightPoints(winner.points);
      }

      notifyListeners();

    } on GameError catch (error) {
      switch (error) {
        case GameError.spotTaken:
          break;
        case GameError.noStepsToUndo:
          break;
        case GameError.outOfBounds:
          break;
      }
    }
  }

  @override
  void undo() {
    try {
      game.undoStep();
      notifyListeners();

    } on GameError catch (error) {

    }
  }

  @override
  void moveBoard() {
    _selectedPoint = null;
  }
}
