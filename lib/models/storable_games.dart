import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';

class GameData {
  int boardSize;
  Side initialSide;
  List<Point> steps;
  GameMode gameMode;

  GameData(this.boardSize, this.initialSide, this.steps, this.gameMode);

  GameData.fromJson(Map<String, dynamic> json)
    : boardSize = json['boardSize'],
      initialSide = sideFromString(json['initialSide']),
      steps = List<Point>.from(json['steps'].map((point) => Point(point['x'], point['y']))),
      gameMode = gameModeFromString(json['gameMode']);

  Map<String, dynamic> toJson() => {
    'boardSize': boardSize,
    'initialSide': initialSide.toString(),
    'steps': steps.map((point) => {
      'x': point.x,
      'y': point.y
    }).toList(),
    'gameMode': gameMode.toString()
  };
}

class StorableGames {
  GameData lastGame;
  List<GameData> replays = [];

  StorableGames();

  StorableGames.fromJson(Map<String, dynamic> json)
    : lastGame = json['lastGame'] != null ? GameData.fromJson(json['lastGame']) : null,
      replays = List<GameData>.from(json['replays'].map((game) => GameData.fromJson(game)));

  Map<String, dynamic> toJson() => {
    'lastGame': lastGame?.toJson(),
    'replays': replays.map((game) => game.toString()).toList()
  };
}
