import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/multiplayer/multiplayer_game.dart';
import 'package:connect_5/models/multiplayer/user.dart';
import 'package:connect_5/util.dart';

enum GameRoomRole {
  player1, player2, spectator,
}

GameRoomRole roleFromInt(int n) {
  switch (n) {
    case 1: return GameRoomRole.player1;
    case 2: return GameRoomRole.player2;
    case 3: return GameRoomRole.spectator;
  }
  return null;
}

int roleToInt(GameRoomRole role) {
  switch (role) {
    case GameRoomRole.player1: return 1;
    case GameRoomRole.player2: return 2;
    case GameRoomRole.spectator: return 3;
  }
  return -1;
}

String roleToString(GameRoomRole role) {
  switch (role) {
    case GameRoomRole.player1: return 'player_1';
    case GameRoomRole.player2: return 'player_2';
    case GameRoomRole.spectator: return 'spectator';
  }
  return '';
}

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
  bool player1Restart;
  bool player2Restart;

  GameRoom(this.id, this.settings, this.player1, this.player2, this.spectators, this.game, this.gameInProgress, this.player1Restart, this.player2Restart);

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
    player1Restart = guardType(json['player1Restart']) ?? false;
    player2Restart = guardType(json['player2Restart']) ?? false;
  }
}
