import 'package:connect_5/components/board_spot_painter.dart';
import 'package:connect_5/models/game.dart';
import 'package:flutter/material.dart';

typedef void HandlerFunction<T>(T value);

class BoardPainter extends CustomPainter {
  static const double LINE_WIDTH = 1;
  static const double CORNER_RADIUS = 6;
  
  final int boardSize;
  final List<List<BoardSpotPainter>> spotPainters;
  final double cornerRadius;
  final bool drawLines;

  BoardPainter({this.boardSize, this.spotPainters, this.drawLines = true, this.cornerRadius = CORNER_RADIUS});

  @override
  void paint(Canvas canvas, Size size) {
    final boardSideLength = size.width;

    final boardRect = Rect.fromLTWH(0, 0, boardSideLength, boardSideLength);
    
    final boardRRect = RRect.fromRectAndRadius(boardRect, Radius.circular(cornerRadius));
    
    final boardPaint = Paint()
      ..color = Color.fromRGBO(240, 210, 180, 1);

    canvas.drawRRect(boardRRect, boardPaint);

    // Paint lines

    final linePaint = Paint()
      ..strokeWidth = LINE_WIDTH
      ..color = Color.fromRGBO(90, 90, 100, 1);

    // Size of each box, including width of the line
    final boxSize = boardSideLength / (boardSize + 1);

    // Get the center of piece with x and y on board, with optionally additional dx dy
    Offset getCenter(int x, int y, {double dx = 0, double dy = 0}) =>
      // Line distance from edge: 1 * boxSize (*0.5 to position center, *0.5 padding)
      Offset((x + 1) * boxSize + dx, (y + 1) * boxSize + dy);

    if (drawLines) {
      for (var i=0; i<boardSize; i++) {
        final halfLineWidth = LINE_WIDTH / 2;
        // Horizontal line
        canvas.drawLine(
          getCenter(0, i, dx: -halfLineWidth),
          getCenter(boardSize - 1, i, dx: halfLineWidth),
          linePaint
        );

        // Vertical line
        canvas.drawLine(
          getCenter(i, 0, dy: -halfLineWidth),
          getCenter(i, boardSize - 1, dy: halfLineWidth),
          linePaint
        );
      }
    }

    for (int x=0; x<boardSize; x++) {
      for (int y=0; y<boardSize; y++) {
        spotPainters[x][y].paint(canvas, getCenter(x, y), boxSize);
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return true;
  }
}
