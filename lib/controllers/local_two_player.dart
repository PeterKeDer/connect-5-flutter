import 'package:connect_5/models/game_mode.dart';
import 'package:flutter/material.dart';
import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/models/game.dart';

class LocalTwoPlayerGameController extends GameController with BoardSpotPaintersMixin {
  Game game;
  final TickerProvider tickerProvider;

  GameMode get gameMode => GameMode.twoPlayers;

  LocalTwoPlayerGameController(this.game, this.tickerProvider) {
    initBoardSpotPainters();
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
      highlightPoints([point]);
      
      final winner = game.winner;
      if (winner != null) {
        highlightPoints(winner.points);
      }

      notifyListeners();

    } on GameError catch (error) {
      switch (error) {
        case GameError.spotTaken:
          break;
        case GameError.noStepsToUndo:
          break;
        case GameError.outOfBounds:
          break;
      }
    }
  }

  @override
  void undo() {
    try {
      game.undoStep();
      notifyListeners();

    } on GameError catch (error) {

    }
  }

  @override
  void moveBoard() {
    selectedPoint = null;
  }
}
