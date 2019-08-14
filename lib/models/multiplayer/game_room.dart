import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/multiplayer/multiplayer_game.dart';
import 'package:connect_5/models/multiplayer/user.dart';
import 'package:connect_5/util.dart';

class GameRoomSettings {
  int boardSize = 15;
  bool allowSpectators = true;
  bool isPublic = true;

  GameRoomSettings();

  GameRoomSettings.fromJson(Map<String, dynamic> json) {
    boardSize = guardType(json['boardSize']) ?? boardSize;
    allowSpectators = guardType(json['allowSpectators']) ?? allowSpectators;
    isPublic = guardType(json['isPublic']) ?? isPublic;
  }
}

class GameRoom {
  final String id;
  GameRoomSettings settings;
  User player1;
  User player2;
  List<User> spectators;
  Game game;
  bool gameInProgress;

  GameRoom(this.id, this.settings, this.player1, this.player2, this.spectators, this.game, this.gameInProgress);

  GameRoom.fromJson(Map<String, dynamic> json) : id = guardTypeNotNull(json['id']) {
    Map<String, dynamic> settingsJson = guardType(json['settings']);
    if (settingsJson != null) {
      settings = GameRoomSettings.fromJson(settingsJson);
    } else {
      settings = GameRoomSettings();
    }

    Map<String, dynamic> player1Json = guardType(json['player1']);
    if (player1Json != null) {
      player1 = User.fromJson(player1Json);
    }

    Map<String, dynamic> player2Json = guardType(json['player2']);
    if (player2Json != null) {
      player2 = User.fromJson(player2Json);
    }

    try {
      spectators = List.from(json['spectators'].map((userJson) => User.fromJson(userJson)));
    } catch (error) {
      spectators = [];
    }

    Map<String, dynamic> gameJson = guardType(json['game']);
    if (gameJson != null) {
      game = MultiplayerGame.fromJson(gameJson);
    }

    gameInProgress = guardType(json['gameInProgress']) ?? false;
  }
}
