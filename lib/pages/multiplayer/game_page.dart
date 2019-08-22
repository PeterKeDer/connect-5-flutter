import 'package:connect_5/controllers/multiplayer_controller.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/components/status_bar.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/helpers/stats_manager.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/multiplayer/game_room.dart';
import 'package:connect_5/models/multiplayer/room_event.dart';
import 'package:connect_5/models/storable_games.dart';
import 'package:connect_5/pages/multiplayer/room_info_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:connect_5/components/game_board.dart';
import 'package:connect_5/controllers/game_controller.dart';

class MultiplayerGamePage extends StatefulWidget {
  @override
  _MultiplayerGamePageState createState() => _MultiplayerGamePageState();
}

// TODO: check for spectator support
class _MultiplayerGamePageState extends State<MultiplayerGamePage> with TickerProviderStateMixin {
  static const double DEFAULT_SPACING = 20;
  static const double MESSAGE_SPACING = 3;
  static const double MESSAGE_PADDING = 6;
  static const MESSAGE_DURATION = Duration(seconds: 3);

  MultiplayerGameController gameController;

  Game get game => gameController.game;

  MultiplayerManager get multiplayerManager => Provider.of(context);

  final _messageListKey = GlobalKey<AnimatedListState>();

  RoomEventMessage _persistentMessage;
  List<RoomEventMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      setState(() {
        gameController = MultiplayerGameController(
          Provider.of<MultiplayerManager>(context),
          Provider.of<SettingsManager>(context),
          _handleEvent,
          this,
        );
        gameController.onGameEvent(_saveGame);

        // Refresh when game updates
        gameController.addListener(() => setState(() {}));

        // If game started and user just joined, it will be too late to receive the game start event
        if (multiplayerManager.currentRoom.gameInProgress && multiplayerManager.game.steps.isEmpty) {
          final gameStartedMessage = RoomEventMessage(localize(context, 'game_started_message'));
          _persistentMessage = RoomEventMessage(_gameTurnMessageText);

          _messages = [
            _persistentMessage,
            gameStartedMessage,
          ];

          Future.delayed(MESSAGE_DURATION, () {
            final index = _messages.indexOf(gameStartedMessage);
            if (index == -1) return;
            final text = _messages.removeAt(index).text;
            _messageListKey.currentState.removeItem(index, (context, animation) => _buildMessageBlock(animation, text));
          });
        }
      });
    });
  }

  @override
  void dispose() {
    gameController.dispose();
    super.dispose();
  }

  Widget _buildMessageBlock(Animation<double> animation, String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: MESSAGE_SPACING),
    child: FadeTransition(
      opacity: animation,
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: SlideTransition(
          position: animation.drive(Tween(begin: Offset(0, -0.5), end: Offset.zero)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: MESSAGE_PADDING, horizontal: 2 * MESSAGE_PADDING),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MESSAGE_PADDING),
              color: Theme.of(context).colorScheme.primary.withAlpha(GameStatusBar.BACKGROUND_ALPHA),
            ),
            child: Text(message),
          ),
        ),
      ),
    ),
  );

  void _handleEvent(RoomEvent event) {
    switch (event.description) {
      case RoomEventDescription.userJoined:
        final userEvent = event as UserEvent;
        final user = userEvent.user;
        if (user.id != multiplayerManager.userId) {
          _displayMessage(localize(context, '\$user_\$role_joined_message', {
            '\$user': user.displayNickname(context),
            '\$role': localize(context, roleToString(userEvent.role)),
          }));
        }
        break;
      case RoomEventDescription.userLeft:
        _displayMessage(localize(context, '\$user_left_message', {
          '\$user': (event as UserEvent).user.displayNickname(context),
        }));
        break;
      case RoomEventDescription.userReconnected:
        final userEvent = event as UserEvent;
        final user = userEvent.user;

        if (userEvent.role != GameRoomRole.spectator) {
          _displayGameTurnMessage();
        }

        if (user.id == multiplayerManager.userId) {
          _displayMessage(localize(context, 'reconnected_message'));
        } else {
          _displayMessage(localize(context, '\$user_reconnected_message', {
            '\$user': user.displayNickname(context),
          }));
        }
        break;
      case RoomEventDescription.userDisconnected:
        final userEvent = event as UserEvent;
        _displayMessage(localize(context, '\$user_disconnected_message', {
          '\$user': userEvent.user.displayNickname(context),
        }));

        if (userEvent.role != GameRoomRole.spectator && userEvent.user.id != multiplayerManager.userId) {
          _showPersistentMessage(localize(context, 'waiting_opponent_reconnect'));
        }
        break;
      case RoomEventDescription.startGame:
        _hidePersistentMessage();
        _displayMessage(localize(context, 'game_started_message'));
        _displayGameTurnMessage();
        break;
      case RoomEventDescription.stepAdded:
        _displayGameTurnMessage();
        break;
      case RoomEventDescription.userSetRestart:
        final user = (event as UserEvent).user;
        if (user.id == multiplayerManager.userId) {
          if (!multiplayerManager.currentRoom.gameInProgress) {
            _showPersistentMessage(localize(context, 'waiting_opponent_restart_message'));
          }
        } else {
          if (!multiplayerManager.currentRoom.gameInProgress) {
            _displayMessage(localize(context, '\$user_set_restart_message', {
              '\$user': user.displayNickname(context),
            }));
          }
        }
        break;
      case RoomEventDescription.gameReset:
        _hidePersistentMessage();
        break;
      case RoomEventDescription.gameEnded:
        _hidePersistentMessage();
        _displayMessage(localize(context, 'game_ended_message'));
    }
  }

  String get _gameTurnMessageText {
    return localize(context, gameController.game.currentSide == gameController.side ? 'your_turn' : 'waiting_opponent_turn');
  }

  void _displayGameTurnMessage() {
    if (gameController.side != null) {
      _setPersistentMessage(_gameTurnMessageText);
    }
  }

  /// Displays a message that disappears after a short duration
  void _displayMessage(String text) {
    final message = RoomEventMessage(text);
    final index = _persistentMessage == null ? 0 : 1;

    _messages.insert(index, message);
    _messageListKey.currentState.insertItem(index);

    Future.delayed(MESSAGE_DURATION, () {
      if (this.mounted) {
        final index = _messages.indexOf(message);
        if (index == -1) return;
        final text = _messages.removeAt(index).text;

        _messageListKey.currentState.removeItem(index, (context, animation) => _buildMessageBlock(animation, text));
      }
    });
  }

  /// Display a message that will only disappear after calling [_hidePersistentMessage], or when another persistent
  /// message need to be shown
  void _showPersistentMessage(String text) {
    _hidePersistentMessage();

    _persistentMessage = RoomEventMessage(text);
    _messages.insert(0, _persistentMessage);
    _messageListKey.currentState.insertItem(0);
  }

  /// Change the current persistent message text without animating. If currently not showing any persistent message,
  /// this will behave the same as [_showPersistentMessage]
  void _setPersistentMessage(String text) {
    if (_persistentMessage == null) {
      _showPersistentMessage(text);
      return;
    }

    _persistentMessage = RoomEventMessage(text);
    _messages[0] = _persistentMessage;

    // Triggers update
    _messageListKey.currentState.setState(() {});
  }

  /// Hide the persistent message
  void _hidePersistentMessage() {
    if (_persistentMessage == null) {
      return;
    }

    final text = _persistentMessage.text;
    _messageListKey.currentState.removeItem(0, (context, animation) => _buildMessageBlock(animation, text));
    _messages.removeAt(0);
    _persistentMessage = null;
  }

  void _handleMenuButtonTapped() {
    PopupActionSheet(
      items: [
        if (multiplayerManager.canResetGame)
          PopupActionSheetItem(
            leading: const Icon(Icons.refresh),
            text: localize(context, 'restart'),
            onTap: _handleRestartButtonTapped,
          ),
        PopupActionSheetItem(
          leading: const Icon(Icons.info_outline),
          text: localize(context, 'room_info'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiplayerRoomInfoPage(),
              )
            );
          }
        ),
        PopupActionSheetItem(
          leading: const Icon(Icons.close),
          text: localize(context, 'quit'),
          onTap: () {
            Provider.of<MultiplayerManager>(context).disconnect();
            Navigator.of(context)..pop()..pop();
          },
        )
      ]
    ).show(context);
  }

  void _saveGame() {
    if (game.isFinished) {
      final gameMode = gameController.gameMode;

      // Save to replays
      final date = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
      Provider.of<GameStorageManager>(context).saveReplay(ReplayData.fromGame(game, gameMode, date, game.winner?.side));
      Provider.of<StatsManager>(context).recordGame(gameMode, game);
    }
  }

  void _handleRestartButtonTapped() {
    if (multiplayerManager.canResetGame) {
      multiplayerManager.resetGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (gameController == null) {
      return Container();
    }

    return ChangeNotifierProvider<GameController>.value(
      value: gameController,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: GameBoard()
              ),
              Positioned(
                top: DEFAULT_SPACING,
                left: DEFAULT_SPACING,
                right: DEFAULT_SPACING,
                child: GameStatusBar(
                  handleMenuButtonTapped: _handleMenuButtonTapped,
                )
              ),
              Positioned(
                top: GameStatusBar.BAR_HEIGHT + DEFAULT_SPACING + MESSAGE_SPACING,
                left: DEFAULT_SPACING,
                right: DEFAULT_SPACING,
                child: AnimatedList(
                  key: _messageListKey,
                  initialItemCount: _messages.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index, animation) {
                    return _buildMessageBlock(animation, _messages[index].text);
                  },
                ),
              ),
              if (multiplayerManager.canResetGame)
                Positioned(
                  bottom: DEFAULT_SPACING,
                  left: DEFAULT_SPACING,
                  right: DEFAULT_SPACING,
                  child: Center(
                    child: RaisedButton.icon(
                      icon: Icon(Icons.refresh),
                      label: Text(localize(context, 'restart')),
                      onPressed: _handleRestartButtonTapped,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
