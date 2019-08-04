import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:flutter/cupertino.dart';

class ReplayGameController extends GameController with BoardSpotPaintersMixin {
  Game game;
  Game originalGame;
  GameMode gameMode;
  var currentStep = 0;

  final Settings settings;
  final TickerProvider tickerProvider;

  ReplayGameController(this.originalGame, this.gameMode, this.settings, this.tickerProvider)
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

      game.addStep(point);
      addPiece(point, prevSide);

      currentStep++;

      if (currentStep == originalGame.steps.length) {
        // Replay is finished
        final winner = originalGame.winner;
        if (winner != null) {
          highlightWinningMoves(winner.points);
        }
      } else {
        highlightLastStep(point);
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
