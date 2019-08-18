import 'package:connect_5/models/multiplayer/game_room.dart';
import 'package:connect_5/models/multiplayer/user.dart';
import 'package:connect_5/util.dart';

enum RoomEventDescription {
  userJoined,
  userLeft,
  userReconnected,
  userDisconnected,
  startGame,
  stepAdded,
  userSetRestart,
  gameReset,
  gameEnded,
}

abstract class RoomEvent {
  RoomEventDescription get description;

  static RoomEvent fromJson(Map<String, dynamic> json) {
    final String description = guardType(json['description']);

    switch (description) {
      case 'user-joined':
        return UserEvent(RoomEventDescription.userJoined, User.fromJson(json['user']), roleFromInt(json['role']));
      case 'user-left':
        return UserEvent(RoomEventDescription.userLeft, User.fromJson(json['user']), roleFromInt(json['role']));
      case 'user-disconnected':
        return UserEvent(RoomEventDescription.userDisconnected, User.fromJson(json['user']), roleFromInt(json['role']));
      case 'user-reconnected':
        return UserEvent(RoomEventDescription.userReconnected, User.fromJson(json['user']), roleFromInt(json['role']));
      case 'start-game':
        return BasicRoomEvent(RoomEventDescription.startGame);
      case 'step-added':
        return BasicRoomEvent(RoomEventDescription.stepAdded);
      case 'user-set-restart':
        return UserEvent(RoomEventDescription.userSetRestart, User.fromJson(json['user']), roleFromInt(json['role']));
      case 'game-reset':
        return BasicRoomEvent(RoomEventDescription.gameReset);
      case 'game-ended':
        return BasicRoomEvent(RoomEventDescription.gameEnded);
    }

    return null;
  }
}

class RoomEventMessage {
  final String text;

  RoomEventMessage(this.text);
}

class BasicRoomEvent extends RoomEvent {
  final RoomEventDescription description;

  BasicRoomEvent(this.description);
}

class UserEvent extends RoomEvent {
  final User user;
  final RoomEventDescription description;
  final GameRoomRole role;

  UserEvent(this.description, this.user, this.role);
}
