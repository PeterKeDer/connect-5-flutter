import 'dart:math' as math;

import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_bot.dart';

class Condition {
  int x;
  int y;
  int orientation;
  Condition(this.x, this.y, this.orientation);
}

class MinMaxBot extends GameBot {
  static const WIN_SCORES = [0, 10, 50, 200, 1000, 100000];
  static const LOSE_SCORES = [0, 10, 50, 200, 1000, 10000];

  Side botSide;
  Game game;

  // Orientations: 0 - horizontal (to right), 1 - slope down forward, 2 - vertical (downwards), 3 - slope down backward
  List<List<List<int>>> winConditions;
  List<List<List<int>>> loseConditions;

  @override
  void initialize(Game game, Side botSide) {
    this.botSide = botSide;
    this.game = game;

    _initConditions();
  }

  @override
  void notifyMove(Point point, Side side) {
    for (final condition in _getAffectedConditions(point.x, point.y)) {
      final x = condition.x, y = condition.y, n = condition.orientation;
      if (side == botSide) {
        if (winConditions[x][y][n] != -1) {
          winConditions[x][y][n]++;
        }
        loseConditions[x][y][n] = -1;
      } else {
        if (loseConditions[x][y][n] != -1) {
          loseConditions[x][y][n]++;
        }
        winConditions[x][y][n] = -1;
      }
    }
  }

  @override
  Point getNextMove(Game game) {
    List<Point> bestPoints = [];
    var highestScore = 0;

    for (var x=0; x<game.board.size; x++) {
      for (var y=0; y<game.board.size; y++) {
        final point = Point(x, y);
        if (game.board.getSpot(point) == BoardSpot.empty) {
          final score = _getScore(point);

          if (score > highestScore) {
            highestScore = score;
            bestPoints = [point];
          } else if (score == highestScore) {
            bestPoints.add(point);
          }
        }
      }
    }

    if (bestPoints.isEmpty) {
      return null;
    }

    return bestPoints[math.Random().nextInt(bestPoints.length)];
  }

  void _initConditions() {
    winConditions = List.generate(game.board.size, (_) => List.generate(game.board.size, (_) => List.filled(4, 0)));
    loseConditions = List.generate(game.board.size, (_) => List.generate(game.board.size, (_) => List.filled(4, 0)));

    // Set all unreachable conditions (on edge) to -1
    for (var i = game.board.size - 4; i < game.board.size; i++) {
      for (var j=0; j<game.board.size; j++) {
        winConditions[i][j][0] = -1;
        winConditions[i][j][1] = -1;
        loseConditions[i][j][0] = -1;
        loseConditions[i][j][1] = -1;

        winConditions[j][i][1] = -1;
        winConditions[j][i][2] = -1;
        winConditions[j][i][3] = -1;
        loseConditions[j][i][1] = -1;
        loseConditions[j][i][2] = -1;
        loseConditions[j][i][3] = -1;
      }
    }

    for (var x=0; x<4; x++) {
      for (var y=0; y<game.board.size; y++) {
        winConditions[x][y][3] = -1;
        loseConditions[x][y][3] = -1;
      }
    }

    // Initialize based on existing steps
    Side side = game.initialSide;
    for (final point in game.steps) {
      notifyMove(point, side);
      side = side == Side.black ? Side.white : Side.black;
    }
  }

  List<Condition> _getAffectedConditions(int x, int y) {
    List<Condition> affected = [];

    final xMinOffset = math.max(0, 5 - (game.board.size - x));
    final xMaxOffset = math.min(4, x);
    final yMinOffset = math.max(0, 5 - (game.board.size - y));
    final yMaxOffset = math.min(4, y);

    // Horizontal
    for (var i = xMinOffset; i <= xMaxOffset; i++) {
      affected.add(Condition(x - i, y, 0));
    }

    // Slope down forward
    for (var i = math.max(xMinOffset, yMinOffset); i <= math.min(xMaxOffset, yMaxOffset); i++) {
      affected.add(Condition(x - i, y - i, 1));
    }

    // Vertical
    for (var i = yMinOffset; i <= yMaxOffset; i++) {
      affected.add(Condition(x, y - i, 2));
    }

    // Slope down backwards
    for (var i = math.max(4 - xMaxOffset, yMinOffset); i <= math.min(4 - xMinOffset, yMaxOffset); i++) {
      affected.add(Condition(x + i, y - i, 3));
    }

    return affected;
  }

  int _getScore(Point point) {
    var score = 0;

    for (final condition in _getAffectedConditions(point.x, point.y)) {
      final x = condition.x, y = condition.y, n = condition.orientation;

      try {
        score += WIN_SCORES[winConditions[x][y][n] + 1];
        score += LOSE_SCORES[loseConditions[x][y][n] + 1];
      } catch (_) {
        continue;
      }
    }
    
    return score;
  }
}
