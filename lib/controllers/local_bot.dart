import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/models/game_bot.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:flutter/material.dart';
import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/models/game.dart';

class LocalBotGameController extends GameController with BoardSpotPaintersMixin {
  static const BOT_WAIT_DURATION = Duration(milliseconds: 200);

  Game game;
  GameBot bot;
  Side botSide;
  final Settings settings;
  final TickerProvider tickerProvider;

  GameMode get gameMode => botSide == Side.black ? GameMode.blackBot : GameMode.whiteBot;

  LocalBotGameController(this.game, this.bot, this.botSide, this.settings, this.tickerProvider) {
    initBoardSpotPainters();

    bot.initialize(game, botSide);

    if (game.steps.isNotEmpty) {
      highlightLastStep(game.steps.last);
    }

    if (game.currentSide == botSide) {
      _startBotMove();
    }
  }

  @override
  void tap(Point point) {
    if (game.isFinished) {
      return;
    }

    if (game.currentSide == botSide) {
      return;
    }

    if (!checkDoubleTapConfirmation(point)) {
      notifyListeners();
      return;
    }

    _addStep(point);
  }

  @override
  void moveBoard() {
    selectedPoint = null;
  }

  void _addStep(Point point) {
    if (point == null) {
      return;
    }

    try {
      final prevSide = game.currentSide;
      game.addStep(point);
      addPiece(point, prevSide);
      bot.notifyMove(point, prevSide);

      removeHighlights();

      final winner = game.winner;
      if (winner != null) {
        highlightWinningMoves(game.winner.points);
      } else {
        highlightLastStep(point);
      }

      gameEventListener();
      notifyListeners();

      if (game.currentSide == botSide && !game.isFinished) {
        _startBotMove();
      }

    } on GameError catch (error) {
      switch (error) {
        case GameError.spotTaken:
          break;
        case GameError.outOfBounds:
          break;
      }
    }
  }

  void _startBotMove() {
    Future.delayed(BOT_WAIT_DURATION, () => bot.getNextMove(game))
      .then(_addStep);
  }
}
