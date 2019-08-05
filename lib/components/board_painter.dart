import 'package:connect_5/components/board_spot_painter.dart';
import 'package:flutter/material.dart';

typedef void HandlerFunction<T>(T value);

class BoardTheme {
  final Color boardColor;
  final Color lineColor;
  final Color blackPieceColor;
  final Color whitePieceColor;
  final Color targetColor;
  final Color highlightColor;

  const BoardTheme({
    this.boardColor = const Color.fromRGBO(240, 210, 180, 1),
    this.lineColor = const Color.fromRGBO(90, 90, 90, 1),
    this.blackPieceColor = Colors.black,
    this.whitePieceColor = Colors.white,
    this.targetColor = Colors.red,
    this.highlightColor = Colors.orange,
  });
}

class BoardPainter extends CustomPainter {
  static const double LINE_WIDTH_RATIO = 0.05;
  static const double CORNER_RADIUS_RATIO = 0.35;
  
  final int boardSize;
  final List<List<BoardSpotPainter>> spotPainters;
  final double cornerRadius;
  final bool drawLines;
  final BoardTheme boardTheme;

  BoardPainter({this.boardSize, this.spotPainters, this.drawLines = true, this.cornerRadius, this.boardTheme = const BoardTheme()});

  @override
  void paint(Canvas canvas, Size size) {
    final boardSideLength = size.width;

    // Size of each box, including width of the line
    final boxSize = boardSideLength / (boardSize + 1);

    final boardRect = Rect.fromLTWH(0, 0, boardSideLength, boardSideLength);
    
    final boardRRect = RRect.fromRectAndRadius(boardRect, Radius.circular(cornerRadius ?? CORNER_RADIUS_RATIO * boxSize));
    
    final boardPaint = Paint()
      ..color = boardTheme.boardColor;

    canvas.drawRRect(boardRRect, boardPaint);

    // Paint lines

    final linePaint = Paint()
      ..strokeWidth = LINE_WIDTH_RATIO * boxSize
      ..color = boardTheme.lineColor;

    // Get the center of piece with x and y on board, with optionally additional dx dy
    Offset getCenter(int x, int y, {double dx = 0, double dy = 0}) =>
      // Line distance from edge: 1 * boxSize (*0.5 to position center, *0.5 padding)
      Offset((x + 1) * boxSize + dx, (y + 1) * boxSize + dy);

    if (drawLines) {
      for (var i=0; i<boardSize; i++) {
        final halfLineWidth = LINE_WIDTH_RATIO * boxSize / 2;
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
        spotPainters[x][y].paint(canvas, getCenter(x, y), boxSize, boardTheme);
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return true;
  }
}
