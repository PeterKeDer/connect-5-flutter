import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/models/multiplayer/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiplayerRoomInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final multiplayerManager = Provider.of<MultiplayerManager>(context);
    final room = multiplayerManager.currentRoom;

    return Scaffold(
      appBar: AppBar(
        title: Text(localize(context, 'room_info')),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            subtitle: Text(localize(context, 'room_settings')),
          ),
          ListTile(
            title: Text(localize(context, 'board_size')),
            trailing: Text('${room.settings.boardSize}'),
          ),
          ListTile(
            title: Text(localize(context, 'allow_spectators')),
            trailing: room.settings.allowSpectators ? Icon(Icons.check) : Icon(Icons.close),
          ),
          ListTile(
            title: Text(localize(context, 'public_room')),
            trailing: room.settings.allowSpectators ? Icon(Icons.check) : Icon(Icons.close),
          ),
          ListTile(
            subtitle: Text(localize(context, 'player_1')),
          ),
          if (room.player1 != null)
            ListTile(
              title: Text(room.player1.displayNickname(context)),
            ),

          ListTile(
            subtitle: Text(localize(context, 'player_2')),
          ),
          if (room.player2 != null)
            ListTile(
              title: Text(room.player2.displayNickname(context)),
            ),

          if (room.settings.allowSpectators)
            ...[
              ListTile(
                subtitle: Text(localize(context, 'spectators')),
              ),
              for (final spectator in room.spectators)
                ListTile(
                  title: Text(spectator.displayNickname(context)),
                )
            ],
        ],
      )
    );
  }
}
