import 'package:connect_5/components/board_painter.dart';
import 'package:connect_5/components/board_spot_painter.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/models/storable_games.dart';
import 'package:connect_5/pages/game_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReplaysPage extends StatelessWidget {
  static const double BOARD_SIZE = 80;
  static const double SPACING = 15;

  List<List<BoardSpotPainter>> _getSpotPainters(ReplayData replay) {
    // Never animated, so ticker provider null is ok
    final spotPainters = List.generate(replay.boardSize, (_) =>
      List.generate(replay.boardSize, (_) => BoardSpotPainter(null))
    );

    Side side = replay.initialSide;
    for (final point in replay.steps) {
      spotPainters[point.x][point.y].addPiece(side);
      side = side == Side.black ? Side.white : Side.black;
    }

    return spotPainters;
  }

  Widget _buildGameListTile(BuildContext context, ReplayData replay, List<List<BoardSpotPainter>> spotPainters) =>
    Container(
      child: InkWell(
        onTap: () => _showReplay(context, replay),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(SPACING),
              child: Container(
                width: BOARD_SIZE,
                height: BOARD_SIZE,
                child: CustomPaint(
                  painter: BoardPainter(
                    boardSize: replay.boardSize,
                    spotPainters: spotPainters,
                    cornerRadius: 3,
                    drawLines: false,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  getString(replay.gameMode),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )
                ),
                Text(
                  '${_getWinnerText(replay.winner)} - ${replay.steps.length} steps',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  replay.date ?? '',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  
  String _getWinnerText(Side winner) {
    if (winner == null) {
      return 'Tie';
    } else if (winner == Side.black) {
      return 'Black Victory';
    } else {
      return 'White Victory';
    }
  }
  
  void _showReplay(BuildContext context, ReplayData replay) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage.replay(replay.gameMode, replay.game),
        fullscreenDialog: true
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final replays = Provider.of<GameStorageManager>(context).games?.replays ?? [];
    final spotPainters = replays.map(_getSpotPainters).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Replays'),
      ),
      body: ListView.separated(
        itemCount: replays.length,
        itemBuilder: (context, i) => _buildGameListTile(context, replays[i], spotPainters[i]),
        separatorBuilder: (context, i) => Divider(
          color: Colors.black45,
          indent: SPACING,
          height: 0,
          endIndent: SPACING
        ),
      )
    );
  }
}
