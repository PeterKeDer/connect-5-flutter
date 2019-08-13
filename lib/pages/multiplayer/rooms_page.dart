import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/models/multiplayer/game_room.dart';
import 'package:connect_5/pages/multiplayer/game_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiplayerRoomsPage extends StatelessWidget {
  static const double SPACING = 15;

  void _handleRoomTapped(BuildContext context, GameRoom room) {
    PopupActionSheet(
      items: [
        PopupActionSheetItem(
          text: 'Player 1',
          onTap: () => _connectToRoom(context, room, 1),
        ),
        PopupActionSheetItem(
          text: 'Player 2',
          onTap: () => _connectToRoom(context, room, 2),
        ),
        PopupActionSheetItem(
          text: 'Spectator',
          onTap: () => _connectToRoom(context, room, 3),
        ),
      ],
    ).show(context);
  }

  void _connectToRoom(BuildContext context, GameRoom room, int role) {
    Provider.of<MultiplayerManager>(context).connect(
      room.id,
      role,
      onJoinSuccess: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplayerGamePage(),
          fullscreenDialog: true,
        )
      ),
      onJoinFail: () => print('Join fail!'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final multiplayerManager = Provider.of<MultiplayerManager>(context);
    final rooms = multiplayerManager.rooms ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(localize(context, 'rooms')),
      ),
      body: rooms.isNotEmpty
        ? ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(rooms[i].id),
            onTap: () => _handleRoomTapped(context, rooms[i]),
          ),
        )
        : Center(
          child: Padding(
            padding: const EdgeInsets.all(SPACING),
            child: Text(
              localize(context, 'no_rooms_message'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.title
            ),
          )
        ),
    );
  }
}
