import 'dart:convert';
import 'dart:io';

import 'package:connect_5/models/storable_games.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class GameStorageManager extends ChangeNotifier {
  static const GAMES_FILENAME = 'games.json';
  static const MAX_REPLAYS = 20;

  static final shared = GameStorageManager();

  var games = StorableGames();

  /// Get the file where games are saved
  Future<File> get _gamesFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$GAMES_FILENAME');
  }

  /// Ensure that the games file exists and contains basic data
  Future<File> get _ensureGamesFile async {
    var file = await _gamesFile;
    
    if (!await file.exists()) {
      file = await file.create();

      final jsondata = StorableGames().toJson();
      final str = json.encode(jsondata);

      await file.writeAsString(str);
    }

    return file;
  }

  /// Save the last game in background, and notify listeners that the last game has changed
  void saveLastGame(GameData gameData) {
    games.lastGame = gameData;
    _writeGames();

    notifyListeners();
  }

  /// Clear the last game
  void clearLastGame() => saveLastGame(null);

  void saveReplay(ReplayData replay) {
    if (games.replays.length >= MAX_REPLAYS) {
      games.replays.removeLast();
    }
    games.replays.insert(0, replay);
    _writeGames();

    notifyListeners();
  }

  /// Write games to file
  Future<void> _writeGames() async {
    final file = await _ensureGamesFile;
    final jsonData = games.toJson();
    await file.writeAsString(json.encode(jsonData));
  }

  /// Read from file to get saved games
  Future<void> readGamesAsync() async {
    final file = await _ensureGamesFile;
    final contentStr = await file.readAsString();
    games = StorableGames.fromJson(json.decode(contentStr));
  }
}
