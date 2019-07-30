import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:flutter/cupertino.dart';

class ReplayGameController extends GameController with BoardSpotPaintersMixin {
  Game game;
  Game originalGame;
  GameMode gameMode;
  var currentStep = 0;

  final TickerProvider tickerProvider;

  ReplayGameController(this.originalGame, this.gameMode, this.tickerProvider)
    : game = Game.createNew(originalGame.board.size, initialSide: originalGame.initialSide)
  {
    initBoardSpotPainters();
  }

  @override
  void tap(Point point) {
    if (currentStep < originalGame.steps.length) {
      final point = originalGame.steps[currentStep];
      final prevSide = game.currentSide;

      removeHighlights();
      highlightPoints([point]);

      game.addStep(point);
      addPiece(point, prevSide);

      currentStep++;

      if (currentStep == originalGame.steps.length) {
        // Replay is finished
        final winner = originalGame.winner;
        if (winner != null) {
          highlightPoints(winner.points);
        }
      }

      notifyListeners();
    }
  }

  @override
  void undo() {

  }

  @override
  void moveBoard() {

  }
}
