enum GameMode {
  twoPlayers, blackBot, whiteBot
}

const GAME_MODES = [
  GameMode.twoPlayers,
  GameMode.blackBot,
  GameMode.whiteBot
];

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
