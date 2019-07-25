enum GameError {
  outOfBounds,
  spotTaken,
  noStepsToUndo
}

enum BoardSpot {
  empty, black, white
}

enum Side {
  black, white
}

class Point {
  int x, y;
  Point(this.x, this.y);

  bool operator ==(p) => p is Point && p.x == x && p.y == y;
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() {
    return 'Point($x, $y)';
  }
}

class WinnerDetails {
  Side side;
  List<Point> points;
  WinnerDetails(this.side, this.points);
}

class Board {
  final int size;
  List<List<BoardSpot>> _spots;

  Board(this._spots)
    : size = _spots.length;

  Board.withSize(this.size)
    : _spots = List.generate(size, (_) => List.filled(size, BoardSpot.empty));

  /// Get the spot at point, throwing OutOfBoardException if point is invalid
  BoardSpot getSpot(Point point) {
    if (!isValid(point)) {
      throw GameError.outOfBounds;
    }
    return _spots[point.x][point.y];
  }

  /// Set the spot at point, throwing OutOfBoardException if point is invalid
  void setSpot(Point point, BoardSpot spot) {
    if (!isValid(point)) {
      throw GameError.outOfBounds;
    }
    _spots[point.x][point.y] = spot;
  }

  /// Returns whether the board is full (no empty spots remaining)
  bool get isFull {
    return _spots.every((col) =>
      col.every((spot) => spot != BoardSpot.empty));
  }

  /// Check if point is within the board bounds
  bool isValid(Point point) {
    return 0 <= point.x && point.x < size && 0 <= point.y && point.y < size;
  }
}

class Game {
  static const int WIN_CONSEC_SPOTS = 5;

  Board board;
  List<Point> steps;
  Side currentSide;
  final Side initialSide;

  Game(this.board, this.steps, this.currentSide, {this.initialSide = Side.black});

  Game.createNew(int size, {this.initialSide = Side.black})
    : board = Board.withSize(size),
      steps = [],
      currentSide = initialSide;

  /// Initialize a game from given steps
  /// Can throw OutOfBoardException and SpotTakenException
  Game.fromSteps(
    this.steps,
    {int size = 15,
    this.initialSide = Side.black}
  ) {
    currentSide = initialSide;
    board = Board.withSize(size);

    steps.forEach(addStep);
  }

  /// Add a step, throws spotTaken error if spot is not empty
  void addStep(Point point) {
    if (board.getSpot(point) != BoardSpot.empty) {
      throw GameError.spotTaken;
    }
    final spot = currentSide == Side.black ? BoardSpot.black : BoardSpot.white;
    board.setSpot(point, spot);
    steps.add(point);

    _shouldRecalculateWinner = true;
    _toggleSide();
  }

  /// Return whether there are any steps to undo
  bool get canUndo {
    return steps.isNotEmpty;
  }

  /// Undo the last step, or throw noStepsToUndo error if there are no steps
  void undoStep() {
    if (!canUndo) {
      throw GameError.noStepsToUndo;
    }
    board.setSpot(steps.removeLast(), BoardSpot.empty);

    _shouldRecalculateWinner = true;
    _toggleSide();
  }

  bool get isFull {
    return board.isFull;
  }

  bool _shouldRecalculateWinner = true;

  WinnerDetails _winner;

  /// Get the winner details (cached), if any, Otherwise null
  WinnerDetails get winner {
    if (_shouldRecalculateWinner) {
      _winner = _getWinner();
      _shouldRecalculateWinner = false;
    }

    return _winner;
  }

  WinnerDetails _getWinner() {
    List<List<Point>> lines = [];

    for (var i=0; i<board.size; i++) {
      // Horizontal lines
      lines.add(List.generate(board.size, (j) => Point(i, j)));

      // Vertical lines
      lines.add(List.generate(board.size, (j) => Point(j, i)));

      // Slope down lines
      lines.add(List.generate(board.size - i, (j) => Point(i + j, j)));
      if (i > 0) {
        lines.add(List.generate(board.size - i, (j) => Point(j, i + j)));
      }

      // Slope up line
      lines.add(List.generate(i + 1, (j) => Point(i - j, j)));
      if (i > 0) {
        lines.add(List.generate(board.size - i, (j) => Point(i + j, board.size - j - 1)));
      }
    }
    
    // Get the first consecutive side
    return lines.map(_getWinDetails).firstWhere((win) => win != null, orElse: () => null);
  }

  /// Check if there are consecutive 5 points with the same side on board
  WinnerDetails _getWinDetails(List<Point> points) {
    if (points.length < WIN_CONSEC_SPOTS) {
      return null;
    }

    BoardSpot prevSpot;
    List<Point> consec = [];

    for (final point in points) {
      final spot = board.getSpot(point);

      if (spot == prevSpot && spot != BoardSpot.empty) {
        consec.add(point);

        if (consec.length >= WIN_CONSEC_SPOTS) {
          final side = spot == BoardSpot.black ? Side.black : Side.white;
          return WinnerDetails(side, consec);
        }
      } else {
        consec = [point];
        prevSpot = spot;
      }
    }

    return null;
  }

  bool get isFinished => winner != null || isFull;

  void _toggleSide() {
    currentSide = currentSide == Side.black ? Side.white : Side.black;
  }
}
