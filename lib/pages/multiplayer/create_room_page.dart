import 'package:connect_5/components/loading_dialog.dart';
import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/pages/multiplayer/game_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiplayerCreateRoomPage extends StatefulWidget {
  @override
  _MultiplayerCreateRoomPageState createState() => _MultiplayerCreateRoomPageState();
}

class _MultiplayerCreateRoomPageState extends State<MultiplayerCreateRoomPage> {
  String roomId = '';
  int boardSize = 15;
  bool allowSpectators = true;
  bool isPublic = true;

  bool get isValid {
    return roomId.trim().isNotEmpty;
  }

  void _handleCreateRoomButtonTapped() {
    // Hide keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    PopupActionSheet(
      title: localize(context, 'join_room'),
      items: [
        PopupActionSheetItem(
          text: localize(context, 'player_1'),
          onTap: () => _createRoom(1),
        ),
        PopupActionSheetItem(
          text: localize(context, 'player_2'),
          onTap: () => _createRoom(2),
        ),
        if (allowSpectators)
          PopupActionSheetItem(
            text: localize(context, 'spectator'),
            onTap: () => _createRoom(3),
          ),
      ],
    ).show(context);
  }

  void _createRoom(int role) async {
    showLoadingDialog(context);

    final multiplayerManager = Provider.of<MultiplayerManager>(context);

    try {
      final room = await multiplayerManager.createRoom(roomId, boardSize, allowSpectators, isPublic);

      multiplayerManager.connect(room.id, role,
        onJoinSuccess: () {
          hideLoadingDialog(context);
          Navigator.of(context)..pop()..push(
            MaterialPageRoute(
              builder: (context) => MultiplayerGamePage(),
              fullscreenDialog: true,
            ),
          );
        },
        onJoinFail: () {
          hideLoadingDialog(context);
          _showError(CreateRoomError.unknown);
        }
      );
    } on CreateRoomError catch (error) {
      print(error);
      hideLoadingDialog(context);
      _showError(error);
    }
  }

  void _showError(CreateRoomError error) {
    String title;
    String message;

    switch (error) {
      case CreateRoomError.invalidRoomId:
        title = localize(context, 'invalid_room_id');
        message = localize(context, 'invalid_room_id_message');
        break;
      case CreateRoomError.roomIdTaken:
        title = localize(context, 'room_id_taken');
        message = localize(context, 'room_id_taken_message');
        break;
      case CreateRoomError.unknown:
        title = localize(context, 'cannot_create_room');
        message = localize(context, 'cannot_create_room_message');
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text(localize(context, 'ok')),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(localize(context, 'create_room')),
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
              onChanged: (roomId) => setState(() => this.roomId = roomId),
            ),
          ),
          ListTile(
            title: Text(localize(context, 'board_size')),
            trailing: Text('$boardSize'),
          ),
          Slider(
            divisions: SettingsManager.MAX_BOARD_SIZE - SettingsManager.MIN_BOARD_SIZE,
            min: SettingsManager.MIN_BOARD_SIZE.toDouble(),
            max: SettingsManager.MAX_BOARD_SIZE.toDouble(),
            value: boardSize.toDouble(),
            onChanged: (value) => setState(() => boardSize = value.round()),
          ),
          SwitchListTile(
            title: Text(localize(context, 'allow_spectators')),
            value: allowSpectators,
            activeColor: primaryColor,
            onChanged: (allowSpectators) => setState(() => this.allowSpectators = allowSpectators),
          ),
          SwitchListTile(
            title: Text(localize(context, 'public_room')),
            value: isPublic,
            activeColor: primaryColor,
            onChanged: (isPublic) => setState(() => this.isPublic = isPublic),
          ),
          ListTile(
            title: RaisedButton(
              child: Text(localize(context, 'create_room')),
              onPressed: isValid ? _handleCreateRoomButtonTapped : null,
            ),
          )
        ],
      ),
    );
  }
}
