import 'package:flutter/material.dart';

enum GameMode {
  twoPlayers, blackBot, whiteBot
}

const GAME_MODES = [
  GameMode.twoPlayers,
  GameMode.blackBot,
  GameMode.whiteBot
];

Widget getIcon(GameMode gameMode, {double size = 25, Color color = Colors.black45}) {
  switch (gameMode) {
    case GameMode.twoPlayers:
      return Icon(Icons.supervisor_account, size: size, color: color);
    case GameMode.blackBot:
      return Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
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
  }
  return null;
}

String getString(GameMode gameMode) {
  switch (gameMode) {
    case GameMode.twoPlayers:
      return 'Two Players';
    case GameMode.blackBot:
      return 'Bot (Black)';
    case GameMode.whiteBot:
    return 'Bot (White)';
  }
  return '';
}
