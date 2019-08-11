import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/multiplayer/multiplayer_game.dart';
import 'package:connect_5/util.dart';

class GameRoomSettings {
  int boardSize = 15;
  bool allowSpectators = true;

  GameRoomSettings.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    boardSize = guardType(json['boardSize']) ?? boardSize;
    allowSpectators = guardType(json['allowSpectators']) ?? allowSpectators;
  }
}

class GameRoom {
  final String id;
  GameRoomSettings settings;
  String player1;
  String player2;
  List<String> spectators;
  Game game;
  bool gameInProgress;

  GameRoom(this.id, this.settings, this.player1, this.player2, this.spectators, this.game, this.gameInProgress);

  GameRoom.fromJson(Map<String, dynamic> json) : id = guardTypeNotNull(json['id']) {
    settings = GameRoomSettings.fromJson(guardType(json['settings']));
    player1 = guardType(json['player1']);
    player2 = guardType(json['player2']);
    spectators = guardType(json['spectators']);

    Map<String, dynamic> gameJson = guardType(json['game']);
    if (gameJson != null) {
      game = MultiplayerGame.fromJson(gameJson);
    }

    gameInProgress = game == null || game.isFinished;
  }
}
