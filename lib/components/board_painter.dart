import 'package:connect_5/components/board_spot_painter.dart';
import 'package:connect_5/models/game.dart';
import 'package:flutter/material.dart';

typedef void HandlerFunction<T>(T value);

class BoardPainter extends CustomPainter {
  static const double LINE_WIDTH = 1;
  static const double CORNER_RADIUS = 6;
  
  final Game game;
  final List<List<BoardSpotPainter>> spotPainters;

  BoardPainter({this.game, this.spotPainters});

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = size.width;

    final boardRect = Rect.fromLTWH(0, 0, boardSize, boardSize);
    
    final boardRRect = RRect.fromRectAndRadius(boardRect, Radius.circular(CORNER_RADIUS));
    
    final boardPaint = Paint()
      ..color = Color.fromRGBO(240, 210, 180, 1);

    canvas.drawRRect(boardRRect, boardPaint);

    // Paint lines

    final linePaint = Paint()
      ..strokeWidth = LINE_WIDTH
      ..color = Color.fromRGBO(90, 90, 100, 1);

    // Size of each box, including width of the line
    final boxSize = boardSize / (game.board.size + 1);

    // Get the center of piece with x and y on board, with optionally additional dx dy
    Offset getCenter(int x, int y, {double dx = 0, double dy = 0}) =>
      // Line distance from edge: 1 * boxSize (*0.5 to position center, *0.5 padding)
      Offset((x + 1) * boxSize + dx, (y + 1) * boxSize + dy);

    for (var i=0; i<game.board.size; i++) {
      final halfLineWidth = LINE_WIDTH / 2;
      // Horizontal line
      canvas.drawLine(
        getCenter(0, i, dx: -halfLineWidth),
        getCenter(game.board.size - 1, i, dx: halfLineWidth),
        linePaint
      );

      // Vertical line
      canvas.drawLine(
        getCenter(i, 0, dy: -halfLineWidth),
        getCenter(i, game.board.size - 1, dy: halfLineWidth),
        linePaint
      );
    }

    for (int x=0; x<game.board.size; x++) {
      for (int y=0; y<game.board.size; y++) {
        spotPainters[x][y].paint(canvas, getCenter(x, y), boxSize);
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return true;
  }
}
