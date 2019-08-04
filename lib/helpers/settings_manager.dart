import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager extends ChangeNotifier {
  static const DOUBLE_TAP_CONFIRM_KEY = 'DOUBLE_TAP_CONFIRM_KEY';
  static const HIGHLIGHT_LAST_STEP_KEY = 'HIGHLIGHT_LAST_STEP_KEY';
  static const HIGHLIGHT_WINNING_MOVES_KEY = 'HIGHLIGHT_WINNING_MOVES_KEY';

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

    notifyListeners();
  }

  bool _shouldDoubleTapConfirm = true;

  bool get shouldDoubleTapConfirm => _shouldDoubleTapConfirm;

  set shouldDoubleTapConfirm(bool value) {
    _shouldDoubleTapConfirm = value;
    preferences.setBool(DOUBLE_TAP_CONFIRM_KEY, value);
    notifyListeners();
  }

  bool _shouldHighlightLastStep = true;

  bool get shouldHighlightLastStep {
    return true;
  }

  set shouldHighlightLastStep(bool value) {
    _shouldHighlightLastStep = value;
    preferences.setBool(HIGHLIGHT_LAST_STEP_KEY, value);
    notifyListeners();
  }

  bool _shouldHighlightWinningMoves = true;

  bool get shouldHighlightWinningMoves {
    return _shouldHighlightWinningMoves;
  }

  set shouldHighlightWinningMoves(bool value) {
    _shouldHighlightWinningMoves = value;
    preferences.setBool(HIGHLIGHT_WINNING_MOVES_KEY, value);
    notifyListeners();
  }
}
