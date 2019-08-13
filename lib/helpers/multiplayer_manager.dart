import 'dart:convert';

import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/multiplayer/game_room.dart';
import 'package:connect_5/models/multiplayer/multiplayer_game.dart';
import 'package:connect_5/secrets.dart' as secrets;
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
}

class UserEvents {
  static const addStep = 'add-step';
}

abstract class MultiplayerGameEventHandler {
  void handleGameStarted(Game game);
  void handleStepAdded(Game game);
  void handleAddStepFailed(Game game);
}

class MultiplayerManager extends ChangeNotifier {
  IO.Socket _socket;

  String nickname = 'TestNickname';

  VoidCallback _joinSuccessHandler;
  VoidCallback _joinFailHandler;

  List<GameRoom> rooms;
  GameRoom currentRoom;

  Side get currentSide {
    if (_socket.id == currentRoom.player1?.id) {
      return Side.black;
    } else if (_socket.id == currentRoom.player2?.id) {
      return Side.white;
    }
    return null;
  }

  MultiplayerGame get game => currentRoom?.game;

  MultiplayerGameEventHandler gameEventHandler;

  void connect(String roomId, int role, {VoidCallback onJoinSuccess, VoidCallback onJoinFail}) async {
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
    _socket.on(Events.failToJoin, (_) {
      currentRoom = null;

      if (_joinFailHandler != null) {
        _joinFailHandler();
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
  }

  void addStep(Point point) {
    _socket.emit(UserEvents.addStep, {
      'point': {
        'x': point.x,
        'y': point.y,
      },
    });
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
}
