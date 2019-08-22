import 'package:connect_5/controllers/game_controller.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/models/multiplayer/room_event.dart';
import 'package:connect_5/util.dart';
import 'package:flutter/material.dart';

class MultiplayerGameController extends GameController with BoardSpotPaintersMixin implements MultiplayerGameEventHandler {
  final MultiplayerManager multiplayerManager;

  final Game _defaultGame; // displayed when game did not start yet
  Game get game => multiplayerManager.game ?? _defaultGame;

  final Settings settings;
  final TickerProvider tickerProvider;

  GameMode get gameMode {
    switch (side) {
      case Side.black:
        return GameMode.multiplayerBlack;
      case Side.white:
        return GameMode.multiplayerWhite;
      default:
        return GameMode.multiplayerSpectate;
    }
  }

  /// Side of the user. If side is null, then user is a spectator
  Side get side => multiplayerManager.currentSide;

  Point lastStep;

  HandlerFunction<RoomEvent> roomEventHandler;

  bool stepTaken = false;

  MultiplayerGameController(this.multiplayerManager, this.settings, this.roomEventHandler, this.tickerProvider)
    : _defaultGame = Game.createNew(multiplayerManager.currentRoom.settings.boardSize)
  {
    initBoardSpotPainters();

    multiplayerManager.gameEventHandler = this;

    if (game.steps.isNotEmpty) {
      highlightLastStep(game.steps.last);
    }
  }

  @override
  void tap(Point point) {
    if (!multiplayerManager.currentRoom.gameInProgress) {
      return;
    }

    if (game.currentSide != side || stepTaken) {
      return;
    }

    if (game.board.getSpot(point) != BoardSpot.empty) {
      return;
    }

    if (!checkDoubleTapConfirmation(point)) {
      notifyListeners();
      return;
    }

    try {
      lastStep = point;
      addPiece(point, side);
      highlightLastStep(point);

      multiplayerManager.addStep(point, onAddStepFailed: _handleAddStepFailed);
      stepTaken = true;

      removeHighlights();

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

  void handleEvent(RoomEvent event) {
    switch (event.description) {
      case RoomEventDescription.userReconnected:
        if ((event as UserEvent).user.id == multiplayerManager.userId) {
          _handleReconnection();
        }
        break;
      case RoomEventDescription.startGame:
        _handleGameStarted();
        break;
      case RoomEventDescription.stepAdded:
        _handleStepAdded();
        break;
      case RoomEventDescription.gameReset:
        _handleGameReset();
        break;
      default:
        break;
    }
    if (roomEventHandler != null) {
      roomEventHandler(event);
    }
  }

  void _handleGameStarted() {
    resetSpotPainters();
    notifyListeners();
  }

  void _handleStepAdded() {
    stepTaken = false;

    if (game.currentSide == side || side == null) {
      // Highlight step taken by other player OR spectating
      removeHighlights();

      addPiece(game.steps.last, toggleSide(side));

      highlightLastStep(game.steps.last);

    } else {
      // Last step was by user - no action needed
      lastStep = null;
    }

    if (game.winner != null) {
      highlightWinningMoves(game.winner.points);
    }

    gameEventListener();

    notifyListeners();
  }

  void _handleAddStepFailed() {
    // Happens when internet is disconnected
    if (lastStep != null) {
      // Remove piece, as it is invalid
      removePiece(lastStep);
      removeHighlights();
      lastStep = null;

      highlightLastStep(game.steps.last);

      notifyListeners();
    }
  }

  void _handleGameReset() {
    resetSpotPainters();
    notifyListeners();
  }

  void _handleReconnection() {
    // Reset game when reconnected in case of missed events / local events not received on server
    resetSpotPainters();

    stepTaken = false;
    initBoardSpotPainters();

    if (game.steps.isNotEmpty) {
      highlightLastStep(game.steps.last);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    multiplayerManager.gameEventHandler = null;
    super.dispose();
  }
}
