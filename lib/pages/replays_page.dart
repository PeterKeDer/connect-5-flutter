import 'package:connect_5/app_localizations.dart';
import 'package:connect_5/components/board_painter.dart';
import 'package:connect_5/components/board_spot_painter.dart';
import 'package:connect_5/helpers/settings_manager.dart';
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

  static const TITLE_TEXT_STYLE = TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
  static const DEFAULT_TEXT_STYLE = TextStyle(fontSize: 16);

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
                    boardTheme: Provider.of<SettingsManager>(context).boardTheme,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  localize(context, getString(replay.gameMode)),
                  style: TITLE_TEXT_STYLE,
                ),
                Text(
                  '${replay.boardSize} x ${replay.boardSize}',
                  style: DEFAULT_TEXT_STYLE,
                ),
                Text(
                  '${localize(context, _getWinnerText(replay.winner))} - ${replay.steps.length} ${localize(context, 'steps')}',
                  style: DEFAULT_TEXT_STYLE,
                ),
                Text(
                  replay.date ?? '',
                  style: DEFAULT_TEXT_STYLE,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  
  String _getWinnerText(Side winner) {
    if (winner == null) {
      return 'tie';
    } else if (winner == Side.black) {
      return 'black_victory';
    } else {
      return 'white_victory';
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
        title: Text(localize(context, 'replays')),
      ),
      body: replays.isNotEmpty
        ? ListView.separated(
          itemCount: replays.length,
          itemBuilder: (context, i) => _buildGameListTile(context, replays[i], spotPainters[i]),
          separatorBuilder: (context, i) => Divider(
            color: Colors.black45,
            indent: SPACING,
            height: 0,
            endIndent: SPACING
          ),
        )
        : Center(
          child: Padding(
            padding: const EdgeInsets.all(SPACING),
            child: Text(
              localize(context, 'no_replays_message'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.title
            ),
          ),
        )
    );
  }
}
