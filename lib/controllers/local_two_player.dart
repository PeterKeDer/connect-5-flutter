import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:flutter/material.dart';
import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/models/game.dart';

class LocalTwoPlayerGameController extends GameController with BoardSpotPaintersMixin {
  Game game;
  final Settings settings;
  final TickerProvider tickerProvider;

  GameMode get gameMode => GameMode.twoPlayers;

  LocalTwoPlayerGameController(this.game, this.settings, this.tickerProvider) {
    initBoardSpotPainters();

    if (game.steps.isNotEmpty) {
      highlightLastStep(game.steps.last);
    }
  }

  @override
  void tap(Point point) {
    if (game.isFinished) {
      return;
    }

    if (!checkDoubleTapConfirmation(point)) {
      notifyListeners();
      return;
    }

    try {
      final prevSide = game.currentSide;
      game.addStep(point);
      addPiece(point, prevSide);

      removeHighlights();

      final winner = game.winner;
      if (winner != null && settings.shouldHighlightWinningMoves) {
        highlightWinningMoves(winner.points);
      } else {
        highlightLastStep(point);
      }

      gameEventListener();
      notifyListeners();

    } on GameError catch (error) {
      switch (error) {
        case GameError.spotTaken:
          break;
        case GameError.outOfBounds:
          break;
      }
    }
  }

  @override
  void moveBoard() {
    selectedPoint = null;
  }
}
