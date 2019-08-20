import 'dart:convert';

import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/multiplayer/game_room.dart';
import 'package:connect_5/models/multiplayer/multiplayer_game.dart';
import 'package:connect_5/models/multiplayer/room_event.dart';
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

  static const roomUpdated = 'room-updated';
}

class UserEvents {
  static const addStep = 'add-step';
  static const restartGame = 'restart-game';
  static const leaveGame = 'leave-game';
}

abstract class MultiplayerGameEventHandler {
  void handleEvent(RoomEvent event);
}

class MultiplayerRoomConnectionHandler {
  VoidCallback joinSuccessHandler;
  HandlerFunction<JoinRoomError> joinFailHandler;
  VoidCallback reconnectFailHandler;

  MultiplayerRoomConnectionHandler({this.joinSuccessHandler, this.joinFailHandler, this.reconnectFailHandler});
}

enum GetRoomError {
  unknown, invalidRoomId, roomNotFound,
}

enum CreateRoomError {
  unknown, invalidRoomId, roomIdTaken,
}

enum JoinRoomError {
  unknown, invalidRole, invalidRoomId, timeout,
}

class MultiplayerManager extends ChangeNotifier {
  IO.Socket _socket;

  String nickname = 'TestNickname';

  MultiplayerRoomConnectionHandler connectionHandler;

  VoidCallback _addStepFailedHandler;

  List<GameRoom> rooms;
  GameRoom currentRoom;

  String userId;

  Side get currentSide {
    if (_socket == null || userId == null) {
      return null;
    }
    if (userId == currentRoom.player1?.id) {
      return Side.black;
    } else if (userId == currentRoom.player2?.id) {
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

  // TODO: TEST THIS SHIT!!!!!!!!
  void _connect(String userId, MultiplayerRoomConnectionHandler connectionHandler) {
    this.connectionHandler = connectionHandler;

    _socket = IO.io(secrets.SERVER_URI, <String, dynamic>{
      'forceNew': true, // create a new connection
      'transports': ['websocket'], // required for iOS
      'query': {
        'userId': userId,
      },
    });

    _registerSocketEvents();
  }

  void disconnect() {
    _socket.emit(UserEvents.leaveGame);

    _socket.close();
    _socket = null;

    notifyListeners();
  }

  void _registerSocketEvents() {
    _socket.on(Events.failToJoin, (data) {
      currentRoom = null;

      if (connectionHandler?.joinFailHandler != null || connectionHandler?.reconnectFailHandler != null) {
        var error = JoinRoomError.unknown;

        if (data is Map<String, dynamic>) {
          switch (data['error']) {
            // Only possible error at this point
            case 'connection_timeout':
              error = JoinRoomError.timeout;
              break;
          }
        }

        if (connectionHandler?.joinFailHandler != null) {
          connectionHandler?.joinFailHandler(error);
          connectionHandler?.joinFailHandler = null; // ? should this be done?
        } else {
          connectionHandler?.reconnectFailHandler();
          connectionHandler?.reconnectFailHandler = null;
        }
      }

      _socket.clearListeners();
      _socket = null;
    });

    _socket.on(Events.roomUpdated, (data) {
      try {
        currentRoom = GameRoom.fromJson(data['room']);
        notifyListeners();

        final event = RoomEvent.fromJson(data['event']);

        gameEventHandler?.handleEvent(event);

        switch (event.description) {
          case RoomEventDescription.userJoined:
            try {
              if ((event as UserEvent).user.id == userId && connectionHandler?.joinSuccessHandler != null) {
                connectionHandler?.joinSuccessHandler();
                connectionHandler?.joinSuccessHandler = null;
              }
            } catch (error) {}
            break;
          case RoomEventDescription.userSetRestart:
            try {
              if ((event as UserEvent).user.id == userId) {
                _localRestartGame = null;
              }
            } catch (error) {}
            break;
          default:
            break;
        }

      } catch (error) {}
    });

    _socket.on(Events.failToAddStep, (data) {
      try {
        currentRoom = GameRoom.fromJson(data['room']);

        if (_addStepFailedHandler != null) {
          _addStepFailedHandler();
          _addStepFailedHandler = null;
        }

        notifyListeners();
      } catch (error) {}
    });
  }

  void addStep(Point point, {VoidCallback onAddStepFailed}) {
    if (_socket.disconnected) {
      onAddStepFailed();
      return;
    }

    _addStepFailedHandler = onAddStepFailed;
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

  void joinRoom(String roomId, GameRoomRole role, MultiplayerRoomConnectionHandler connectionHandler) async {
    if (_socket != null) {
      return;
    }

    try {
      final response = await http.post(
        '${secrets.SERVER_URI}/join-room',
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'roomId': roomId,
          'role': roleToInt(role),
          'nickname': nickname,
        }),
      );

      if (response.statusCode == 200) {
        userId = json.decode(response.body)['userId'];

        if (userId == null) {
          connectionHandler?.joinFailHandler(JoinRoomError.unknown);
          return;
        }

        _connect(userId, connectionHandler);

      } else {
        final errorString = json.decode(response.body)['error'] as String;

        var error = JoinRoomError.unknown;

        switch (errorString) {
          case 'invalid_room_id':
            error = JoinRoomError.invalidRoomId;
            break;
          case 'invalid_role':
            error = JoinRoomError.invalidRole;
            break;
        }

        connectionHandler?.joinFailHandler(error);
        return;
      }
    } catch (error) {
      connectionHandler?.joinFailHandler(JoinRoomError.unknown);
      return;
    }
  }

  void createRoom(
    String roomId,
    GameRoomRole role,
    int boardSize,
    bool allowSpectators,
    bool isPublic,
    MultiplayerRoomConnectionHandler connectionHandler,
    {HandlerFunction<CreateRoomError> createRoomErrorHandler}
  ) async {
    try {
      final response = await http.post(
        '${secrets.SERVER_URI}/create-room',
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': roomId,
          'role': roleToInt(role),
          'settings': {
            'boardSize': boardSize,
            'allowSpectators': allowSpectators,
            'isPublic': isPublic,
          },
        }),
      );
      print(response.body);

      if (response.statusCode == 200) {
        userId = json.decode(response.body)['userId'];

        if (userId == null) {
          connectionHandler?.joinFailHandler(JoinRoomError.unknown);
          return;
        }

// TODO: figure out hanlder issue: which Error type to use
// definitely needs joinroom error to handle stuffs like reconnection, but still needs create room error for messages
// maybe handler for join room error, and throw create room errors? but that would be inconsistent/confusing
// TODO: actually make these three functions into a single RoomConnectionHandler delegate class
        _connect(userId, connectionHandler);

      } else {
        final error = json.decode(response.body)['error'] as String;

        switch (error) {
          case 'room_id_taken':
            createRoomErrorHandler(CreateRoomError.roomIdTaken);
            break;
          case 'invalid_room_id':
            createRoomErrorHandler(CreateRoomError.invalidRoomId);
            break;
          default:
            createRoomErrorHandler(CreateRoomError.unknown);
            break;
        }
      }
    } catch (error) {
      createRoomErrorHandler(CreateRoomError.unknown);
    }
  }
}
