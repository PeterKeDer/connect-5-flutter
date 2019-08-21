import 'package:connect_5/components/dialogs.dart';
import 'package:connect_5/components/game_room_tile.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/models/multiplayer/game_room.dart';
import 'package:connect_5/pages/multiplayer/game_page.dart';
import 'package:connect_5/pages/multiplayer/join_room_mixin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiplayerSearchRoomPage extends StatefulWidget {
  @override
  _MultiplayerSearchRoomPageState createState() => _MultiplayerSearchRoomPageState();
}

class _MultiplayerSearchRoomPageState extends State<MultiplayerSearchRoomPage> with MultiplayerJoinRoomMixin {
  String _roomId = '';
  GameRoom _room;

  bool get isValid {
    return _roomId.trim().isNotEmpty;
  }

  void _handleSearchButtonTapped() async {
    if (!isValid) {
      return;
    }

    showLoadingDialog(context);

    try {
      final room = await Provider.of<MultiplayerManager>(context).getRoom(_roomId);

      hideDialog(context);

      setState(() {
        this._room = room;
      });
    } on GetRoomError catch (error) {
      hideDialog(context);

      String title;
      String message;

      switch (error) {
        case GetRoomError.invalidRoomId:
          title = 'invalid_room_id';
          message = 'invalid_room_id_message';
          break;
        case GetRoomError.roomNotFound:
          title = 'room_not_found';
          message = 'room_not_found_message';
          break;
        case GetRoomError.unknown:
          title = 'cannot_get_room';
          message = 'cannot_get_room_message';
          break;
      }

      showAlertDialog(
        context: context,
        title: localize(context, title),
        message: localize(context, message),
      );
    }
  }

  void _showGamePage() {
    Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(localize(context, 'join_room_by_id')),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: TextField(
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                labelText: localize(context, 'room_id'),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (roomId) => setState(() => this._roomId = roomId),
              onSubmitted: (_) => _handleSearchButtonTapped(),
            ),
            trailing: RaisedButton(
              child: Text(localize(context, 'search')),
              onPressed: isValid ? _handleSearchButtonTapped : null,
            ),
          ),
          if (_room != null)
            GameRoomTile(
              room: _room,
              onTap: () => startJoiningRoom(context, _room, onJoinSuccess: _showGamePage),
            ),
        ],
      ),
    );
  }
}
