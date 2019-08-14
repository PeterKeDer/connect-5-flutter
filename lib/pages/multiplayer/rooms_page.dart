import 'package:connect_5/components/loading_dialog.dart';
import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/models/multiplayer/game_room.dart';
import 'package:connect_5/pages/multiplayer/create_room_page.dart';
import 'package:connect_5/pages/multiplayer/game_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiplayerRoomsPage extends StatelessWidget {
  static const double SPACING = 15;

  void _handleRoomTapped(BuildContext context, GameRoom room) {
    PopupActionSheet(
      title: localize(context, 'join_room'),
      items: [
        PopupActionSheetItem(
          text: localize(context, 'player_1'),
          onTap: () => _connectToRoom(context, room, 1),
        ),
        PopupActionSheetItem(
          text: localize(context, 'player_2'),
          onTap: () => _connectToRoom(context, room, 2),
        ),
        PopupActionSheetItem(
          text: localize(context, 'spectator'),
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

  void _handleShowOptions(BuildContext context) {
    PopupActionSheet(
      items: [
        PopupActionSheetItem(
          leading: Icon(Icons.add),
          text: localize(context, 'create_room'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiplayerCreateRoomPage(),
            ),
          ),
        ),
        PopupActionSheetItem(
          leading: Icon(Icons.search),
          text: localize(context, 'join_room_by_id'),
        ),
      ],
    ).show(context);
  }

  void _handleRefreshButtonTapped(BuildContext context) async {
    showLoadingDialog(context);

    final rooms = await Provider.of<MultiplayerManager>(context).getRooms();

    Navigator.pop(context);

    if (rooms == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localize(context, 'connection_failed')),
          content: Text(localize(context, 'connection_failed_message')),
          actions: <Widget>[
            FlatButton(
              child: Text(localize(context, 'ok')),
              textColor: Theme.of(context).colorScheme.primary,
              onPressed: () => Navigator.of(context)..pop()..pop(),
            ),
          ],
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final multiplayerManager = Provider.of<MultiplayerManager>(context);
    final rooms = multiplayerManager.rooms ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(localize(context, 'rooms')),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _handleRefreshButtonTapped(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.more_horiz),
        onPressed: () => _handleShowOptions(context),
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
