import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Settings {
  bool get shouldDoubleTapConfirm;
  bool get shouldHighlightLastStep;
  bool get shouldHighlightWinningMoves;
  int get boardSize;
}

class SettingsManager extends ChangeNotifier implements Settings {
  static const DOUBLE_TAP_CONFIRM_KEY = 'DOUBLE_TAP_CONFIRM_KEY';
  static const HIGHLIGHT_LAST_STEP_KEY = 'HIGHLIGHT_LAST_STEP_KEY';
  static const HIGHLIGHT_WINNING_MOVES_KEY = 'HIGHLIGHT_WINNING_MOVES_KEY';

  static const BOARD_SIZE_KEY = 'BOARD_SIZE_KEY';
  static const MIN_BOARD_SIZE = 9;
  static const MAX_BOARD_SIZE = 19;

  SharedPreferences preferences;

  bool isLoaded = false;

  SettingsManager() {
    SharedPreferences.getInstance().then(_initialize);
  }

  void _initialize(SharedPreferences preferences) {
    this.preferences = preferences;
    isLoaded = true;

    _shouldDoubleTapConfirm = preferences.getBool(DOUBLE_TAP_CONFIRM_KEY) ?? true;
    _shouldHighlightLastStep = preferences.getBool(HIGHLIGHT_LAST_STEP_KEY) ?? true;
    _shouldHighlightWinningMoves = preferences.getBool(HIGHLIGHT_WINNING_MOVES_KEY) ?? true;
    _boardSize = preferences.getInt(BOARD_SIZE_KEY) ?? 15;

    notifyListeners();
  }

  bool _shouldDoubleTapConfirm;

  bool get shouldDoubleTapConfirm => _shouldDoubleTapConfirm;

  set shouldDoubleTapConfirm(bool value) {
    _shouldDoubleTapConfirm = value;
    preferences.setBool(DOUBLE_TAP_CONFIRM_KEY, value);
    notifyListeners();
  }

  bool _shouldHighlightLastStep;

  bool get shouldHighlightLastStep => _shouldHighlightLastStep;

  set shouldHighlightLastStep(bool value) {
    _shouldHighlightLastStep = value;
    preferences.setBool(HIGHLIGHT_LAST_STEP_KEY, value);
    notifyListeners();
  }

  bool _shouldHighlightWinningMoves;

  bool get shouldHighlightWinningMoves => _shouldHighlightWinningMoves;

  set shouldHighlightWinningMoves(bool value) {
    _shouldHighlightWinningMoves = value;
    preferences.setBool(HIGHLIGHT_WINNING_MOVES_KEY, value);
    notifyListeners();
  }

  int _boardSize;

  int get boardSize => _boardSize;

  set boardSize(int value) {
    if (MIN_BOARD_SIZE <= value && value <= MAX_BOARD_SIZE) {
      _boardSize = value;
      preferences.setInt(BOARD_SIZE_KEY , value);
      notifyListeners();
    }
  }
}
