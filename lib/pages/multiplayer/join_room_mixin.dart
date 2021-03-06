
import 'package:connect_5/components/dialogs.dart';
import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/helpers/settings_manager.dart';
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
            onTap: () => _connectToRoom(context, room, GameRoomRole.player1, onJoinSuccess),
          ),
        if (room.player2 == null)
          PopupActionSheetItem(
            text: localize(context, 'player_2'),
            onTap: () => _connectToRoom(context, room, GameRoomRole.player2, onJoinSuccess),
          ),
        if (room.settings.allowSpectators)
          PopupActionSheetItem(
            text: localize(context, 'spectator'),
            onTap: () => _connectToRoom(context, room, GameRoomRole.spectator, onJoinSuccess),
          ),
      ],
    ).show(context);
  }

  void _connectToRoom(BuildContext context, GameRoom room, GameRoomRole role, VoidCallback onJoinSuccess) {
    showLoadingDialog(context);

    final nickname = Provider.of<SettingsManager>(context).multiplayerNickname;

    Provider.of<MultiplayerManager>(context).joinRoom(nickname, room.id, role,
      MultiplayerRoomConnectionHandler(
        joinSuccessHandler: () {
          hideDialog(context);

          if (onJoinSuccess != null) {
            onJoinSuccess();
          }
        },
        joinFailHandler: (error) => _showErrorDialog(context, error),
        reconnectFailHandler: () {
          showAlertDialog(
            context: context,
            title: localize(context, 'reconnect_failed'),
            message: localize(context, 'reconnect_failed_message'),
            confirmButtonAction: () => Navigator.popUntil(context, (r) => r.isFirst),
          );
        }
      ),
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
      case JoinRoomError.timeout:
        title = 'join_connection_timeout';
        message = 'join_connection_timeout_message';
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
