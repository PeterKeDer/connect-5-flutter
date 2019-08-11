import 'dart:convert';

import 'package:connect_5/models/multiplayer/game_room.dart';
import 'package:connect_5/secrets.dart' as secrets;
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class MultiplayerManager extends ChangeNotifier {
  IO.Socket _socket;

  void connect() async {
    if (_socket != null) {
      return;
    }

    // TODO: get from server
    final roomId = 'roomId';

    _socket = IO.io(secrets.SERVER_URI, <String, dynamic>{
      'transports': ['websocket'], // required for iOS
      'query': {
        'roomId': roomId,
        'role': 1,
        'nickname': 'TestNickname',
      }
    });

    // TODO: wait for success response (user-joined) or failed response (failed-to-join)

    _registerSocketEvents();
  }

  void _registerSocketEvents() {
    _socket.on('connect', (_) {
      print('Connected to socket.');
    });

    // TODO: register to other game events
  }

  List<GameRoom> rooms;

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
