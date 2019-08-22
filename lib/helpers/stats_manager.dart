import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:connect_5/models/stats.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsManager extends ChangeNotifier {
  List<StatGroup> statGroups;

  SharedPreferences preferences;

  static const KEY_PREFIX = 'STATS_';

  final _totalGamesPlayed = StoredStat('total_games_played', 'TOTAL_GAMES_PLAYED');
  final _totalBlackVictory = StoredStat('total_black_victory', 'TOTAL_BLACK_VICTORY');
  final _totalWhiteVictory = StoredStat('total_white_victory', 'TOTAL_WHITE_VICTORY');

  final _twoPlayersGamesPlayed = StoredStat('games_played', 'TWO_PLAYERS_GAMES_PLAYED');
  final _twoPlayersBlackVictory = StoredStat('black_victory', 'TWO_PLAYERS_BLACK_VICTORY');
  final _twoPlayersWhiteVictory = StoredStat('white_victory', 'TWO_PLAYERS_WHITE_VICTORY');

  final _botBlackGamesPlayed = StoredStat('games_played', 'BOT_BLACK_GAMES_PLAYED');
  final _botBlackGamesWon = StoredStat('games_won', 'BOT_BLACK_GAMES_WON');
  final _botBlackGamesLost = StoredStat('games_lost', 'BOT_BLACK_GAMES_LOST');

  final _botWhiteGamesPlayed = StoredStat('games_played', 'BOT_WHITE_GAMES_PLAYED');
  final _botWhiteGamesWon = StoredStat('games_won', 'BOT_WHITE_GAMES_WON');
  final _botWhiteGamesLost = StoredStat('games_lost', 'BOT_WHITE_GAMES_LOST');

  final _multiplayerGamesPlayed = StoredStat('games_played', 'MULTIPLAYER_GAMES_PLAYED');
  final _multiplayerGamesWon = StoredStat('games_won', 'MULTIPLAYER_GAMES_WON');
  final _multiplayerGamesLost = StoredStat('games_lost', 'MULTIPLAYER_GAMES_LOST');

  final _multiplayerGamesPlayedAsBlack = StoredStat('games_played', 'MULTIPLAYER_GAMES_PLAYED_AS_BLACK');
  final _multiplayerGamesWonAsBlack = StoredStat('games_won', 'MULTIPLAYER_GAMES_WON_AS_BLACK');
  final _multiplayerGamesLostAsBlack = StoredStat('games_lost', 'MULTIPLAYER_GAMES_LOST_AS_BLACK');

  final _multiplayerGamesPlayedAsWhite = StoredStat('games_played', 'MULTIPLAYER_GAMES_PLAYED_AS_WHITE');
  final _multiplayerGamesWonAsWhite = StoredStat('games_won', 'MULTIPLAYER_GAMES_WON_AS_WHITE');
  final _multiplayerGamesLostAsWhite = StoredStat('games_lost', 'MULTIPLAYER_GAMES_LOST_AS_WHITE');

  Future<void> initAsync() {
    return SharedPreferences.getInstance().then(_initialize);
  }

  void recordGame(GameMode gameMode, Game game) {
    if (gameMode == GameMode.multiplayerSpectate) return;

    _totalGamesPlayed.storedValue++;

    final winner = game.winner?.side;

    if (winner == Side.black) {
      _totalBlackVictory.storedValue++;
    } else if (winner == Side.white) {
      _totalWhiteVictory.storedValue++;
    }

    switch (gameMode) {
      case GameMode.twoPlayers:
        _twoPlayersGamesPlayed.storedValue++;

        if (winner == Side.black) {
          _twoPlayersBlackVictory.storedValue++;
        } else if (winner == Side.white) {
          _twoPlayersWhiteVictory.storedValue++;
        }
        break;

      case GameMode.blackBot:
        _botBlackGamesPlayed.storedValue++;

        if (winner == Side.black) {
          _botBlackGamesLost.storedValue++;
        } else if (winner == Side.white) {
          _botBlackGamesWon.storedValue++;
        }
        break;

      case GameMode.whiteBot:
        _botWhiteGamesPlayed.storedValue++;

        if (winner == Side.black) {
          _botWhiteGamesWon.storedValue++;
        } else if (winner == Side.white) {
          _botWhiteGamesLost.storedValue++;
        }
        break;

      case GameMode.multiplayerBlack:
        _multiplayerGamesPlayed.storedValue++;
        _multiplayerGamesPlayedAsBlack.storedValue++;

        if (winner == Side.black) {
          _multiplayerGamesWon.storedValue++;
          _multiplayerGamesWonAsBlack.storedValue++;
        } else if (winner == Side.white) {
          _multiplayerGamesLost.storedValue++;
          _multiplayerGamesLostAsBlack.storedValue++;
        }
        break;

      case GameMode.multiplayerWhite:
        _multiplayerGamesPlayed.storedValue++;
        _multiplayerGamesPlayedAsWhite.storedValue++;

        if (winner == Side.black) {
          _multiplayerGamesLost.storedValue++;
          _multiplayerGamesLostAsWhite.storedValue++;
        } else if (winner == Side.white) {
          _multiplayerGamesWon.storedValue++;
          _multiplayerGamesWonAsWhite.storedValue++;
        }
        break;

      default:
        break;
    }

    _save();

    notifyListeners();
  }

  void clearStats() {
    for (final statGroup in statGroups) {
      for (final stat in statGroup.stats) {
        if (stat is StoredStat) {
          stat.storedValue = 0;
        }
      }
    }

    _save();

    notifyListeners();
  }

  void _initialize(SharedPreferences preferences) {
    this.preferences = preferences;

    _initializeStatGroups();

    for (final statGroup in statGroups) {
      for (final stat in statGroup.stats) {
        if (stat is StoredStat) {
          stat.storedValue = preferences.getInt(_getKey(stat)) ?? 0;
        }
      }
    }
  }

  void _initializeStatGroups() {
    statGroups = [
      StatGroup('general', [
        _totalGamesPlayed,
        _totalBlackVictory,
        _totalWhiteVictory,
      ]),
      StatGroup('two_players', [
        _twoPlayersGamesPlayed,
        _twoPlayersBlackVictory,
        _twoPlayersWhiteVictory,
      ]),
      StatGroup('player_vs_bot_black', [
        _botBlackGamesPlayed,
        _botBlackGamesWon,
        _botBlackGamesLost,
        ComputedStat('win_rate', () => _getWinRateString(_botBlackGamesWon.storedValue, _botBlackGamesPlayed.storedValue)),
      ]),
      StatGroup('player_vs_bot_white', [
        _botWhiteGamesPlayed,
        _botWhiteGamesWon,
        _botWhiteGamesLost,
        ComputedStat('win_rate', () => _getWinRateString(_botWhiteGamesWon.storedValue, _botWhiteGamesPlayed.storedValue)),
      ]),
      StatGroup('multiplayer', [
        _multiplayerGamesPlayed,
        _multiplayerGamesWon,
        _multiplayerGamesLost,
        ComputedStat('win_rate', () => _getWinRateString(
          _multiplayerGamesWon.storedValue,
          _multiplayerGamesPlayed.storedValue
        )),
      ]),
      StatGroup('multiplayer_as_black', [
        _multiplayerGamesPlayedAsBlack,
        _multiplayerGamesWonAsBlack,
        _multiplayerGamesLostAsBlack,
        ComputedStat('win_rate', () => _getWinRateString(
          _multiplayerGamesWonAsBlack.storedValue,
          _multiplayerGamesPlayedAsBlack.storedValue
        )),
      ]),
      StatGroup('multiplayer_as_white', [
        _multiplayerGamesPlayedAsWhite,
        _multiplayerGamesWonAsWhite,
        _multiplayerGamesLostAsWhite,
        ComputedStat('win_rate', () => _getWinRateString(
          _multiplayerGamesWonAsWhite.storedValue,
          _multiplayerGamesPlayedAsWhite.storedValue
        )),
      ]),
    ];
  }

  Future<void> _save() async {
    List<Future> futures = [];

    for (final statGroup in statGroups) {
      for (final stat in statGroup.stats) {
        if (stat is StoredStat) {
          _saveStat(stat);
        }
      }
    }

    await Future.wait(futures);
  }

  Future<bool> _saveStat(StoredStat stat) {
    return preferences.setInt(_getKey(stat), stat.storedValue);
  }

  String _getWinRateString(int win, int total) {
    final winRate = (total == 0 ? 0 : (win * 100 / total)).toStringAsFixed(2);
    return '$winRate%';
  }

  String _getKey(StoredStat stat) => KEY_PREFIX + stat.key;
}
