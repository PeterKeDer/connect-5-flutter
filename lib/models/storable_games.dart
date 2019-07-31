import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';

class GameData {
  int boardSize;
  Side initialSide;
  List<Point> steps;
  GameMode gameMode;

  GameData(this.boardSize, this.initialSide, this.steps, this.gameMode);

  /// Create GameData from Game, in addition to game mode
  GameData.fromGame(Game game, GameMode gameMode)
    : this(game.board.size, game.initialSide, game.steps, gameMode);

  GameData.fromJson(Map<String, dynamic> json)
    : boardSize = json['boardSize'],
      initialSide = sideFromString(json['initialSide']),
      steps = List<Point>.from(json['steps'].map((point) => Point(point['x'], point['y']))),
      gameMode = gameModeFromString(json['gameMode']);
  
  /// Get Game from GameData
  Game get game => Game.fromSteps(steps, size: boardSize, initialSide: initialSide);

  Map<String, dynamic> toJson() => {
    'boardSize': boardSize,
    'initialSide': initialSide.toString(),
    'steps': steps.map((point) => {
      'x': point.x,
      'y': point.y
    }).toList(),
    'gameMode': gameMode.toString(),
  };
}

class ReplayData extends GameData {
  Side winner;
  String date;

  ReplayData(int boardSize, Side initialSide, List<Point> steps, GameMode gameMode, this.date, this.winner)
    : super(boardSize, initialSide, steps, gameMode);

  /// Get ReplayData from Game, with game mode, date, and winner side
  ReplayData.fromGame(Game game, GameMode gameMode, this.date, this.winner) : super.fromGame(game, gameMode);
  
  ReplayData.fromJson(Map<String, dynamic> json)
    : winner = json['winner'] != null ? sideFromString(json['winner']) : null,
      date = json['date'],
      super.fromJson(json);
  
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'winner': winner?.toString(),
    'date': date
  };
}

class StorableGames {
  GameData lastGame;
  List<ReplayData> replays = [];

  StorableGames();

  StorableGames.fromJson(Map<String, dynamic> json)
    : lastGame = json['lastGame'] != null ? GameData.fromJson(json['lastGame']) : null,
      replays = List<ReplayData>.from(json['replays'].map((game) => ReplayData.fromJson(game)));

  Map<String, dynamic> toJson() => {
    'lastGame': lastGame?.toJson(),
    'replays': replays.map((game) => game.toJson()).toList()
  };
}
