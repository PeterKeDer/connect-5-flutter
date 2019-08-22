import 'package:flutter/material.dart';

enum GameMode {
  twoPlayers, blackBot, whiteBot, multiplayerBlack, multiplayerWhite, multiplayerSpectate
}

const LOCAL_GAME_MODES = [
  GameMode.twoPlayers,
  GameMode.blackBot,
  GameMode.whiteBot,
];

GameMode gameModeFromString(String str) => GameMode.values.firstWhere((gameMode) => gameMode.toString() == str);

Widget getIcon(GameMode gameMode, {double size = 25, Color color = Colors.black45}) {
  switch (gameMode) {
    case GameMode.twoPlayers:
      return Icon(Icons.supervisor_account, size: size, color: color);
    case GameMode.blackBot:
      return Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(size / 2),
        ),
      );
    case GameMode.whiteBot:
      return Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(size / 2),
        ),
      );
    default:
      return null;
  }
}

String getDisplayString(GameMode gameMode) {
  switch (gameMode) {
    case GameMode.twoPlayers:
      return 'two_players';
    case GameMode.blackBot:
      return 'bot_black';
    case GameMode.whiteBot:
      return 'bot_white';
    case GameMode.multiplayerBlack:
      return 'multiplayer';
    case GameMode.multiplayerWhite:
      return 'multiplayer';
    case GameMode.multiplayerSpectate:
      return 'spectating';
  }
  return '';
}
