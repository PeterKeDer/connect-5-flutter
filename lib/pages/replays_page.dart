import 'package:connect_5/components/board_painter.dart';
import 'package:connect_5/components/board_spot_painter.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/pages/game_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReplaysPage extends StatelessWidget {
  static const double BOARD_SIZE = 80;
  static const double SPACING = 10;

  List<List<BoardSpotPainter>> _getSpotPainters(Game game) {
    // Never animated, so ticker provider null is ok
    final spotPainters = List.generate(game.board.size, (_) =>
      List.generate(game.board.size, (_) => BoardSpotPainter(null))
    );

    Side side = game.initialSide;
    for (final point in game.steps) {
      spotPainters[point.x][point.y].addPiece(side);
      side = side == Side.black ? Side.white : Side.black;
    }

    return spotPainters;
  }

  Widget _buildGameListTile(BuildContext context, Game game, GameMode gameMode, Side winner) =>
    Container(
      child: InkWell(
        onTap: () => _showReplay(context, game, gameMode),
        child: Row(
          children: <Widget>[
            Padding(padding: const EdgeInsets.all(SPACING)),
            Container(
              // padding: const EdgeInsets.all(SPACING),
              width: BOARD_SIZE,
              height: BOARD_SIZE,
              child: CustomPaint(
                painter: BoardPainter(
                  game: game,
                  spotPainters: _getSpotPainters(game),
                  cornerRadius: 0,
                  drawLines: false,
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(SPACING)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  getString(gameMode),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  )
                ),
                Padding(padding: const EdgeInsets.only(top: SPACING)),
                Text(
                  _getWinnerText(winner),
                  style: TextStyle(fontSize: 16),
                )
              ],
            )
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
  
  void _showReplay(BuildContext context, Game game, GameMode gameMode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage.replay(gameMode, game),
        fullscreenDialog: true
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameDatas = Provider.of<GameStorageManager>(context).games?.replays ?? [];
    final games = gameDatas.map((gameData) => Game.fromGameData(gameData)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Replays'),
      ),
      body: ListView.builder(
        itemExtent: BOARD_SIZE + 2 * SPACING,
        itemCount: games.length,
        itemBuilder: (context, i) => _buildGameListTile(context, games[i], gameDatas[i].gameMode, gameDatas[i].winner)
      ),
    );
  }
}
