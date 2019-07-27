import 'package:connect_5/models/game_mode.dart';
import 'package:flutter/material.dart';
import 'package:connect_5/components/board_spot_painter.dart';
import 'package:connect_5/models/game.dart';

abstract class GameController extends ChangeNotifier {
  Game get game;
  GameMode get gameMode;
  TickerProvider get tickerProvider;
  List<List<BoardSpotPainter>> spotPainters;

  // Handle events
  void tap(Point point);
  void undo();
  void moveBoard();
}

mixin BoardSpotPaintersMixin on GameController {
  bool isDoubleTapConfirmationEnabled = true; 

  Point _sp;
  Point get selectedPoint => _sp;
  set selectedPoint(Point point) {
    if (_sp != null) {
      removePiece(_sp);
      removeTarget(_sp);
    }
    _sp = point;
    if (_sp != null) {
      addTransparentPiece(_sp, game.currentSide);
      addTarget(_sp);
    }
  }

  void initBoardSpotPainters() {
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
          addPiece(point, spot == BoardSpot.black ? Side.black : Side.white);
        }
      }
    }
  }

  void addPiece(Point point, Side side) {
    spotPainters[point.x][point.y].addPieceAnimated(side);
  }

  void addTransparentPiece(Point point, Side side) {
    spotPainters[point.x][point.y].addTransparentPieceAnimated(side);
  }

  void removePiece(Point point) {
    spotPainters[point.x][point.y].removePieceAnimated();
  }

  /// Returns false if needed to tap again on the same spot to proceed
  bool checkDoubleTapConfirmation(Point point) {
    if (!isDoubleTapConfirmationEnabled) {
      return true;
    }

    if (game.board.getSpot(point) != BoardSpot.empty) {
      selectedPoint = null;
      return false;
    }

    if (point == selectedPoint) {
      selectedPoint = null;
      return true;

    } else {
      selectedPoint = point;
      return false;
    }
  }

  void addTarget(Point point) {
    spotPainters[point.x][point.y].addTargetAnimated();
  }

  void removeTarget(Point point) {
    spotPainters[point.x][point.y].removeTargetAnimated();
  }

  void highlightPoints(List<Point> points) {
    for (final point in points) {
      spotPainters[point.x][point.y].addHighlightAnimated();
    }
  }

  void removeHighlights() {
    for (final row in spotPainters) {
      for (final painter in row) {
        if (painter.isHighlighted) {
          painter.removeHighlightAnimated();
        }
      }
    }
  }
}
