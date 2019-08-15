
import 'package:connect_5/components/dialogs.dart';
import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/models/multiplayer/game_room.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin MultiplayerJoinRoomMixin {
  void startJoiningRoom(BuildContext context, GameRoom room, {VoidCallback onJoinSuccess}) {
    if (room.player1 != null && room.player2 != null && !room.settings.allowSpectators) {
      showAlertDialog(
        context: context,
        title: localize(context, 'cannot_join_room'),
        message: localize(context, 'room_full_message'),
      );

      return;
    }

    PopupActionSheet(
      title: localize(context, 'join_room'),
      items: [
        if (room.player1 == null)
          PopupActionSheetItem(
            text: localize(context, 'player_1'),
            onTap: () => _connectToRoom(context, room, 1, onJoinSuccess),
          ),
        if (room.player2 == null)
          PopupActionSheetItem(
            text: localize(context, 'player_2'),
            onTap: () => _connectToRoom(context, room, 2, onJoinSuccess),
          ),
        if (room.settings.allowSpectators)
          PopupActionSheetItem(
            text: localize(context, 'spectator'),
            onTap: () => _connectToRoom(context, room, 3, onJoinSuccess),
          ),
      ],
    ).show(context);
  }

  void _connectToRoom(BuildContext context, GameRoom room, int role, VoidCallback onJoinSuccess) {
    showLoadingDialog(context);

    Provider.of<MultiplayerManager>(context).connect(room.id, role,
      onJoinSuccess: () {
        hideDialog(context);

        if (onJoinSuccess != null) {
          onJoinSuccess();
        }
      },
      onJoinFail: (error) => _showErrorDialog(context, error),
    );
  }

  void _showErrorDialog(BuildContext context, JoinRoomError error) {
    hideDialog(context);

    String title;
    String message;

    switch (error) {
      case JoinRoomError.invalidRole:
        title = 'join_invalid_role';
        message = 'join_invalid_role_message';
        break;
      case JoinRoomError.invalidRoomId:
        title = 'join_invalid_room_id';
        message = 'join_invalid_room_id_message';
        break;
      case JoinRoomError.unknown:
        title = 'cannot_join_room';
        message = 'cannot_join_room_message';
        break;
    }

    showAlertDialog(
      context: context,
      title: localize(context, title),
      message: localize(context, message),
    );
  }
}
