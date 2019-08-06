import 'package:connect_5/models/game.dart';
import 'package:connect_5/models/game_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatGroup {
  String title;
  List<Stat> stats;
  StatGroup(this.title, this.stats);
}

abstract class Stat {
  final String title;
  String get value;

  Stat(this.title);
}

class StoredStat extends Stat {
  final String key;
  int storedValue = 0;

  String get value => '$storedValue';

  StoredStat(String title, this.key) : super(title);
}

typedef String ComputeFunction();

class ComputedStat extends Stat {
  final ComputeFunction compute;

  String get value => compute();

  ComputedStat(String title, this.compute) : super(title);
}

class StatsManager extends ChangeNotifier {
  List<StatGroup> statGroups;

  SharedPreferences preferences;

  static const KEY_PREFIX = 'STATS_';

  final _totalGamesPlayed = StoredStat('Total Games Played', 'TOTAL_GAMES_PLAYED');
  final _totalBlackVictory = StoredStat('Total Black Victory', 'TOTAL_BLACK_VICTORY');
  final _totalWhiteVictory = StoredStat('Total White Victory', 'TOTAL_WHITE_VICTORY');

  final _twoPlayersGamesPlayed = StoredStat('Games Played', 'TWO_PLAYERS_GAMES_PLAYED');
  final _twoPlayersBlackVictory = StoredStat('Black Victory', 'TWO_PLAYERS_BLACK_VICTORY');
  final _twoPlayersWhiteVictory = StoredStat('White Victory', 'TWO_PLAYERS_WHITE_VICTORY');

  final _botBlackGamesPlayed = StoredStat('Games Played', 'BOT_BLACK_GAMES_PLAYED');
  final _botBlackGamesWon = StoredStat('Games Won', 'BOT_BLACK_GAMES_WON');
  final _botBlackGamesLost = StoredStat('Games Lost', 'BOT_BLACK_GAMES_LOST');

  final _botWhiteGamesPlayed = StoredStat('Games Played', 'BOT_WHITE_GAMES_PLAYED');
  final _botWhiteGamesWon = StoredStat('Games Won', 'BOT_WHITE_GAMES_WON');
  final _botWhiteGamesLost = StoredStat('Games Lost', 'BOT_WHITE_GAMES_LOST');

  Future<void> initAsync() {
    return SharedPreferences.getInstance().then(_initialize);
  }

  void recordGame(GameMode gameMode, Game game) {
    print('recording game');

    _totalGamesPlayed.storedValue++;

    if (gameMode == GameMode.twoPlayers) {
      _twoPlayersGamesPlayed.storedValue++;
    } else if (gameMode == GameMode.blackBot) {
      _botBlackGamesPlayed.storedValue++;
    } else {
      _botWhiteGamesPlayed.storedValue++;
    }

    final winner = game.winner?.side;
    if (winner == Side.black) {
      _totalBlackVictory.storedValue++;

      if (gameMode == GameMode.twoPlayers) {
        _twoPlayersBlackVictory.storedValue++;
      } else if (gameMode == GameMode.blackBot) {
        _botBlackGamesLost.storedValue++;
      } else {
        _botWhiteGamesWon.storedValue++;
      }
    } else if (winner == Side.white) {
      _totalWhiteVictory.storedValue++;

      if (gameMode == GameMode.twoPlayers) {
        _twoPlayersWhiteVictory.storedValue++;
      } else if (gameMode == GameMode.blackBot) {
        _botBlackGamesWon.storedValue++;
      } else {
        _botWhiteGamesLost.storedValue++;
      }
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
      StatGroup('General', [
        _totalGamesPlayed,
        _totalBlackVictory,
        _totalWhiteVictory,
      ]),
      StatGroup('Two Players', [
        _twoPlayersGamesPlayed,
        _twoPlayersBlackVictory,
        _twoPlayersWhiteVictory,
      ]),
      StatGroup('Player vs Bot (Black)', [
        _botBlackGamesPlayed,
        _botBlackGamesWon,
        _botBlackGamesLost,
        ComputedStat('Win Rate', () => _getWinRateString(_botBlackGamesWon.storedValue, _botBlackGamesPlayed.storedValue)),
      ]),
      StatGroup('Player vs Bot (White)', [
        _botWhiteGamesPlayed,
        _botWhiteGamesWon,
        _botWhiteGamesLost,
        ComputedStat('Win Rate', () => _getWinRateString(_botWhiteGamesWon.storedValue, _botWhiteGamesPlayed.storedValue)),
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
    final winRate = (total == 0 ? 0 : (win / total)).toStringAsFixed(2);
    return '$winRate%';
  }

  String _getKey(StoredStat stat) => KEY_PREFIX + stat.key;
}
