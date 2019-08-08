import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/components/board_painter.dart';
import 'package:connect_5/components/board_spot_painter.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/models/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> with TickerProviderStateMixin {
  static const TARGET_DELAY_DURATION = Duration(milliseconds: 400);
  static const PIECE_DELAY_DURATION = Duration(milliseconds: 600);
  static const REPLAY_DELAY_DURATION = Duration(seconds: 3);

  static const BOARD_SIZE = 9;
  static const INITIAL_STEPS = [
    Point(4, 4),
    Point(3, 4),
    Point(4, 5),
    Point(4, 3),
    Point(3, 3),
    Point(5, 2),
  ];
  static const STEPS = [
    Point(2, 5),
    Point(5, 4),
    Point(5, 5),
    Point(3, 5),
    Point(2, 2),
    Point(6, 6),
    Point(1, 1),
  ];
  static const WINNING_MOVES = [
    Point(1, 1),
    Point(2, 2),
    Point(3, 3),
    Point(4, 4),
    Point(5, 5),
  ];

  List<List<BoardSpotPainter>> _spotPainters;

  @override
  void initState() {
    super.initState();

    _playTutorial().catchError((_) {});
  }

  Future<void> _playTutorial() async {
    _spotPainters = List.generate(BOARD_SIZE, (_) =>
      List.generate(BOARD_SIZE, (_) =>
        BoardSpotPainter(this)..addListener(() => setState(() {}))
      )
    );

    var side = Side.black;
    BoardSpotPainter prevPainter;

    for (final point in INITIAL_STEPS) {
      final painter = _spotPainters[point.x][point.y];

      painter.addPiece(side);
      side = toggleSide(side);

      if (point == INITIAL_STEPS.last) {
        painter.addHighlight();
        prevPainter = painter;
      }
    }

    for (final point in STEPS) {
      if (!await wait(PIECE_DELAY_DURATION)) return;

      final painter = _spotPainters[point.x][point.y];

      painter.addTransparentPieceAnimated(side);
      painter.addTargetAnimated();

      if (!await wait(TARGET_DELAY_DURATION)) return;

      painter.addPieceAnimated(side);
      painter.addHighlightAnimated();
      painter.removeTargetAnimated();

      side = toggleSide(side);

      prevPainter?.removeHighlightAnimated();
      prevPainter = painter;
    }

    for (final point in WINNING_MOVES) {
      _spotPainters[point.x][point.y].addHighlightAnimated();
    }

    if (!await wait(REPLAY_DELAY_DURATION)) return;

    if (this.mounted) {
      _playTutorial();
    }
  }

  Future<bool> wait(Duration duration) async {
    await Future.delayed(duration);
    return this.mounted;
  }

  @override
  void dispose() {
    for (final row in _spotPainters) {
      for (final painter in row) {
        painter.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localize(context, 'help')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              localize(context, 'help_message'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.title
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    foregroundPainter: BoardPainter(
                      boardSize: BOARD_SIZE,
                      spotPainters: _spotPainters,
                      boardTheme: Provider.of<SettingsManager>(context).boardTheme,
                    ),
                  ),
                ),
              ),
            ),
            RaisedButton(
              child: Text(localize(context, 'done')),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }
}
