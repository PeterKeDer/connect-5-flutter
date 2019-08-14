import 'package:connect_5/controllers/multiplayer_controller.dart';
import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/components/popup_action_sheet.dart';
import 'package:connect_5/components/status_bar.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/helpers/stats_manager.dart';
import 'package:connect_5/helpers/storage_manager.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/models/multiplayer/multiplayer_game.dart';
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

  MultiplayerGameController gameController;

  MultiplayerGame get game => gameController.game;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      setState(() {
        gameController = MultiplayerGameController(
          Provider.of<MultiplayerManager>(context),
          Provider.of<SettingsManager>(context),
          this,
        );
        gameController.onGameEvent(_saveGame);
      });
    });
  }

  void _handleMenuButtonTapped() {
    PopupActionSheet(
      items: [
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
      // TODO: add correct game modes
      final gameMode = GameMode.twoPlayers;

      // Save to replays
      final date = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
      Provider.of<GameStorageManager>(context).saveReplay(ReplayData.fromGame(game, gameMode, date, game.winner?.side));
      Provider.of<StatsManager>(context).recordGame(gameMode, game);
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
            ],
          ),
        ),
      ),
    );
  }
}
