import 'package:flutter/material.dart';
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

  static const APP_BRIGHTNESS_KEY = 'APP_BRIGHTNESS_KEY';
  static const APP_BRIGHTNESS = {
    'Light': Brightness.light,
    'Dark': Brightness.dark
  };

  static const APP_ACCENT_KEY = 'APP_ACCENT_KEY';
  static const APP_ACCENT = {
    'Blue': Colors.blue,
    'Red': Colors.red,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Grey': Colors.grey
  };

  SharedPreferences preferences;

  Future<void> initAsync() {
    return SharedPreferences.getInstance().then(_initialize);
  }

  void _initialize(SharedPreferences preferences) {
    this.preferences = preferences;

    _shouldDoubleTapConfirm = preferences.getBool(DOUBLE_TAP_CONFIRM_KEY) ?? true;
    _shouldHighlightLastStep = preferences.getBool(HIGHLIGHT_LAST_STEP_KEY) ?? true;
    _shouldHighlightWinningMoves = preferences.getBool(HIGHLIGHT_WINNING_MOVES_KEY) ?? true;
    _boardSize = preferences.getInt(BOARD_SIZE_KEY) ?? 15;
    _appBrightnessString = preferences.getString(APP_BRIGHTNESS_KEY) ?? APP_BRIGHTNESS.keys.first;
    _appAccentString = preferences.getString(APP_ACCENT_KEY) ?? APP_ACCENT.keys.first;

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

  ThemeData get appTheme => ThemeData(
    brightness: APP_BRIGHTNESS[_appBrightnessString],
    primarySwatch: APP_ACCENT[_appAccentString],
  );

  String _appBrightnessString;

  String get appBrightnessString => _appBrightnessString;

  set appBrightnessString(String value) {
    _appBrightnessString = value;
    preferences.setString(APP_BRIGHTNESS_KEY, value);
    notifyListeners();
  }

  String _appAccentString;

  String get appAccentString => _appAccentString;

  set appAccentString(String value) {
    _appAccentString = value;
    preferences.setString(APP_ACCENT_KEY, value);
    notifyListeners();
  }
}
