import 'package:connect_5/components/dialogs.dart';
import 'package:connect_5/components/game_room_tile.dart';
import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/pages/multiplayer/create_room_page.dart';
import 'package:connect_5/pages/multiplayer/game_page.dart';
import 'package:connect_5/pages/multiplayer/join_room_mixin.dart';
import 'package:connect_5/pages/multiplayer/search_room_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiplayerRoomsPage extends StatelessWidget with MultiplayerJoinRoomMixin {
  static const double SPACING = 15;

  void _handleShowOptions(BuildContext context) {
    PopupActionSheet(
      items: [
        PopupActionSheetItem(
          leading: Icon(Icons.add),
          text: localize(context, 'create_room'),
          onTap: () => _handleCreateRoom(context),
        ),
        PopupActionSheetItem(
          leading: Icon(Icons.search),
          text: localize(context, 'join_room_by_id'),
          onTap: () => _handleJoinRoomById(context),
        ),
      ],
    ).show(context);
  }

  void _handleCreateRoom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiplayerCreateRoomPage(),
      ),
    );
  }

  void _handleJoinRoomById(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiplayerSearchRoomPage(),
      ),
    );
  }

  void _handleRefreshButtonTapped(BuildContext context) async {
    showLoadingDialog(context);

    final rooms = await Provider.of<MultiplayerManager>(context).getRooms();

    Navigator.pop(context);

    if (rooms == null) {
      showAlertDialog(
        context: context,
        title: localize(context, 'connection_failed'),
        message: localize(context, 'connection_failed_message'),
      );
    }
  }

  void _showGamePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiplayerGamePage(),
        fullscreenDialog: true,
      ),
    );
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
        ? ListView.separated(
          itemCount: rooms.length,
          itemBuilder: (context, i) => GameRoomTile(
            room: rooms[i],
            onTap: () => startJoiningRoom(context, rooms[i], onJoinSuccess: () => _showGamePage(context))
          ),
          separatorBuilder: (context, i) => Divider(
            color: Theme.of(context).textTheme.caption.color,
            indent: SPACING,
            height: 0,
            endIndent: SPACING
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
