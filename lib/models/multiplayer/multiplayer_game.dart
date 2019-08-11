import 'package:connect_5/models/game.dart';
import 'package:connect_5/util.dart';

Side getSide(int side) => side == 1 ? Side.black : Side.white;
List<Point> parsePoints(json) => guardTypeNotNull<List<Map<String, dynamic>>>(json)
  .map((pointJson) => Point(guardTypeNotNull(pointJson['x']), guardTypeNotNull(pointJson['y'])));

class MultiplayerGame implements Game {
  Board board;
  Side currentSide;
  Side initialSide;
  List<Point> steps;
  WinnerDetails winner;

  bool get isFull => board.isFull;
  bool get isFinished => isFull || winner != null;

  MultiplayerGame.fromJson(Map<String, dynamic> json)
    : board = Board.withSize(guardTypeNotNull(json['size'])),
      currentSide = getSide(guardTypeNotNull(json['currentSide'])),
      initialSide = getSide(guardTypeNotNull(json['initialSide'])),
      steps = parsePoints(json['steps'])
  {
    final Map<String, dynamic> winnerMap = guardType(json['winner']);
    if (winnerMap != null) {
      final side = getSide(guardType(winnerMap['side']));
      final points = parsePoints(winnerMap['points']);
      winner = WinnerDetails(side, points);
    }

    var side = initialSide;
    for (final point in steps) {
      board.setSpot(point, side == Side.black ? BoardSpot.black : BoardSpot.white);
      side = toggleSide(side);
    }
  }

  void addStep(Point point, {bool addToSteps = true}) {}
}
