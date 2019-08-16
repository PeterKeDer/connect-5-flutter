import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/models/multiplayer/game_room.dart';
import 'package:connect_5/models/multiplayer/user.dart';
import 'package:flutter/material.dart';

class GameRoomTile extends StatelessWidget {
  final GameRoom room;
  final VoidCallback onTap;

  GameRoomTile({this.room, this.onTap});

  Widget _buildTextRow(List<Widget> children) => Padding(
    padding: const EdgeInsets.all(2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    ),
  );

  String _getPlayerText(BuildContext context, User player) {
    if (player == null) {
      return '--';
    } else {
      return player.displayNickname(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildTextRow([
              Text(room.id, style: Theme.of(context).textTheme.headline),
              Text('${room.settings.boardSize} x ${room.settings.boardSize}'),
            ]),
            _buildTextRow([
              Text(localize(context, 'player_1')),
              Text(_getPlayerText(context, room.player1)),
            ]),
            _buildTextRow([
              Text(localize(context, 'player_2')),
              Text(_getPlayerText(context, room.player2)),
            ]),
            _buildTextRow([
              Text(localize(context, 'spectators')),
              Text(room.settings.allowSpectators
                ? '${room.spectators.length}'
                : localize(context, 'not_allowed')
              ),
            ]),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
