import 'dart:convert';

import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/multiplayer/game_room.dart';
import 'package:connect_5/models/multiplayer/multiplayer_game.dart';
import 'package:connect_5/secrets.dart' as secrets;
import 'package:connect_5/util.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class Events {
  static const connection = 'connection';
  static const failToJoin = 'fail-to-join';
  static const userJoined = 'user-joined';
  static const userDisconnected = 'user-disconnected';
  static const startGame = 'start-game';
  static const stepAdded = 'step-added';
  static const failToAddStep = 'fail-to-add-step';
  static const userSetRestart = 'user-set-restart';
  static const gameReset = 'game-reset';
}

class UserEvents {
  static const addStep = 'add-step';
  static const restartGame = 'restart-game';
}

abstract class MultiplayerGameEventHandler {
  void handleGameStarted(Game game);
  void handleStepAdded(Game game);
  void handleAddStepFailed(Game game);
  void handleGameReset(Game game);
}

enum GetRoomError {
  unknown, invalidRoomId, roomNotFound,
}

enum CreateRoomError {
  unknown, invalidRoomId, roomIdTaken,
}

enum JoinRoomError {
  unknown, invalidRole, invalidRoomId,
}

class MultiplayerManager extends ChangeNotifier {
  IO.Socket _socket;

  String nickname = 'TestNickname';

  VoidCallback _joinSuccessHandler;
  HandlerFunction<JoinRoomError> _joinFailHandler;

  List<GameRoom> rooms;
  GameRoom currentRoom;

  String get userId => _socket?.id;

  Side get currentSide {
    if (_socket == null) {
      return null;
    }
    if (_socket.id == currentRoom.player1?.id) {
      return Side.black;
    } else if (_socket.id == currentRoom.player2?.id) {
      return Side.white;
    }
    return null;
  }

  MultiplayerGame get game => currentRoom?.game;

  MultiplayerGameEventHandler gameEventHandler;

  /// Temporary stores if user wants to restart game
  bool _localRestartGame;

  /// Can reset when game exist but no longer in process (due to finishing or player leaving),
  /// is not spectator, and is not already restarting
  bool get canResetGame {
    if (_localRestartGame != null) {
      return _localRestartGame;
    }

    if (game == null || currentRoom.gameInProgress) {
      return false;
    }

    switch (currentSide) {
      case Side.black:
        return !currentRoom.player1Restart;
      case Side.white:
        return !currentRoom.player2Restart;
    }
    return false;
  }

  void connect(String roomId, int role, {VoidCallback onJoinSuccess, HandlerFunction<JoinRoomError> onJoinFail}) async {
    // Roles: 1 - player1, 2 - player2, 3 - spectator
    _joinSuccessHandler = onJoinSuccess;
    _joinFailHandler = onJoinFail;

    if (_socket != null) {
      return;
    }

    _socket = IO.io(secrets.SERVER_URI, <String, dynamic>{
      'forceNew': true, // create a new connection
      'transports': ['websocket'], // required for iOS
      'query': {
        'roomId': roomId,
        'role': role,
        'nickname': nickname,
      },
    });

    _registerSocketEvents();
  }

  void disconnect() {
    _socket.close();
    _socket = null;

    notifyListeners();
  }

  void _registerSocketEvents() {
    _socket.on(Events.failToJoin, (data) {
      currentRoom = null;

      if (_joinFailHandler != null) {
        var error = JoinRoomError.unknown;
        if (data is Map<String, dynamic>) {
          switch (data['error']) {
            case 'invalid_room_id':
              error = JoinRoomError.invalidRoomId;
              break;
            case 'invalid_role':
              error = JoinRoomError.invalidRole;
              break;
          }
        }

        _joinFailHandler(error);
        _joinFailHandler = null;
      }

      _socket.clearListeners();
      _socket = null;
    });

    _socket.on(Events.userJoined, (data) {
      try {
        currentRoom = GameRoom.fromJson(data['room']);

        if (data['user']['id'] == _socket.id && _joinSuccessHandler != null) {
          _joinSuccessHandler();
          _joinSuccessHandler = null;
        }

        notifyListeners();

      } catch (error) {}
    });

    _socket.on(Events.userDisconnected, (data) {
      try {
        currentRoom = GameRoom.fromJson(data['room']);
        notifyListeners();
      } catch (error) {}
    });

    _socket.on(Events.startGame, (data) {
      try {
        currentRoom = GameRoom.fromJson(data['room']);

        gameEventHandler?.handleGameStarted(game);

        notifyListeners();
      } catch (error) {}
    });

    _socket.on(Events.stepAdded, (data) {
      try {
        currentRoom = GameRoom.fromJson(data['room']);

        gameEventHandler?.handleStepAdded(game);

        notifyListeners();
      } catch (error) {}
    });

    _socket.on(Events.failToAddStep, (data) {
      try {
        currentRoom = GameRoom.fromJson(data['room']);

        gameEventHandler?.handleAddStepFailed(game);

        notifyListeners();
      } catch (error) {}
    });

    _socket.on(Events.userSetRestart, (data) {
      try {
        currentRoom = GameRoom.fromJson(data['room']);

        _localRestartGame = null;

        notifyListeners();
      } catch (error) {}
    });

    _socket.on(Events.gameReset, (data) {
      try {
        currentRoom = GameRoom.fromJson(data['room']);

        gameEventHandler?.handleGameReset(game);

        notifyListeners();
      } catch (error) {}
    });
  }

  void addStep(Point point) {
    _socket.emit(UserEvents.addStep, {
      'point': {
        'x': point.x,
        'y': point.y,
      },
    });
  }

  void resetGame() {
    _localRestartGame = true;
    if (canResetGame) {
      _socket.emit(UserEvents.restartGame);
    }

    notifyListeners();
  }

  Future<List<GameRoom>> getRooms() async {
    try {
      final response = await http.get('${secrets.SERVER_URI}/rooms');

      final roomsData = json.decode(response.body)['rooms'];
      rooms = List.from(roomsData.map((data) => GameRoom.fromJson(data)));

      notifyListeners();

      return rooms;

    } catch (error) {
      print('Error while getting rooms: $error');
      return null;
    }
  }

  Future<GameRoom> getRoom(String roomId) async {
    try {
      final response = await http.get(Uri.encodeFull('${secrets.SERVER_URI}/rooms/$roomId'));

      if (response.statusCode == 200) {
        final roomJson = json.decode(response.body)['room'];
        return GameRoom.fromJson(roomJson);

      } else {
        final error = json.decode(response.body)['error'] as String;

        switch (error) {
          case 'invalid_room_id':
            throw GetRoomError.invalidRoomId;
          case 'room_not_found':
            throw GetRoomError.roomNotFound;
        }

        throw GetRoomError.unknown;
      }
    } on GetRoomError catch (error) {
      throw error;
    } catch (error) {
      throw GetRoomError.unknown;
    }
  }

  Future<GameRoom> createRoom(String roomId, int boardSize, bool allowSpectators, bool isPublic) async {
    try {
      final response = await http.post(
        '${secrets.SERVER_URI}/create-room',
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': roomId,
          'settings': {
            'boardSize': boardSize,
            'allowSpectators': allowSpectators,
            'isPublic': isPublic,
          },
        }),
      );

      if (response.statusCode == 200) {
        final roomJson = json.decode(response.body)['room'];
        return GameRoom.fromJson(roomJson);

      } else {
        final error = json.decode(response.body)['error'] as String;

        switch (error) {
          case 'room_id_taken':
            throw CreateRoomError.roomIdTaken;
          case 'invalid_room_id':
            throw CreateRoomError.invalidRoomId;
        }

        throw CreateRoomError.unknown;
      }
    } on CreateRoomError catch (error) {
      throw error;
    } catch (error) {
      throw CreateRoomError.unknown;
    }
  }
}
