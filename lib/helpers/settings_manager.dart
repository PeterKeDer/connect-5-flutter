import 'package:connect_5/components/board_painter.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Settings {
  bool get shouldDoubleTapConfirm;
  bool get shouldHighlightLastStep;
  bool get shouldHighlightWinningMoves;
  int get boardSize;
}

class SettingsManager extends ChangeNotifier implements Settings {
  static const LOCALE_KEY = 'LOCALE_KEY';

  static const DOUBLE_TAP_CONFIRM_KEY = 'DOUBLE_TAP_CONFIRM_KEY';
  static const HIGHLIGHT_LAST_STEP_KEY = 'HIGHLIGHT_LAST_STEP_KEY';
  static const HIGHLIGHT_WINNING_MOVES_KEY = 'HIGHLIGHT_WINNING_MOVES_KEY';

  static const BOARD_SIZE_KEY = 'BOARD_SIZE_KEY';
  static const MIN_BOARD_SIZE = 9;
  static const MAX_BOARD_SIZE = 19;

  static const APP_DARK_MODE_KEY = 'APP_DARK_MODE_KEY';

  static const APP_ACCENT_KEY = 'APP_ACCENT_KEY';
  static const APP_ACCENT = {
    'accent_blue': Colors.blue,
    'accent_red': Colors.red,
    'accent_green': Colors.green,
    'accent_orange': Colors.orange,
    'accent_grey': Colors.grey
  };

  static const BOARD_THEME_KEY = 'BOARD_THEME_KEY';
  static const BOARD_THEME = {
    'board_theme_classic': BoardTheme(),
    'board_theme_classic_darker': BoardTheme(
      boardColor: Color.fromRGBO(200, 180, 150, 1),
      whitePieceColor: Color.fromRGBO(245, 245, 245, 1),
      targetColor: Color.fromRGBO(210, 50, 50, 1),
      highlightColor: Color.fromRGBO(220, 140, 0, 1),
    ),
    'board_theme_night': BoardTheme(
      boardColor: Color.fromRGBO(15, 20, 25, 1),
      lineColor: Color.fromRGBO(180, 190, 200, 1),
      blackPieceColor: Color.fromRGBO(80, 90, 120, 1),
      whitePieceColor: Color.fromRGBO(240, 245, 255, 1),
      highlightColor: Color.fromRGBO(80, 200, 220, 1),
      targetColor: Color.fromRGBO(100, 220, 200, 1),
    ),
    'board_theme_blue': BoardTheme(
      boardColor: Color.fromRGBO(210, 220, 230, 1),
      targetColor: Color.fromRGBO(20, 80, 255, 1),
      highlightColor: Color.fromRGBO(90, 140, 255, 1),
    ),
    'board_theme_red': BoardTheme(
      boardColor: Color.fromRGBO(240, 205, 200, 1),
      targetColor: Color.fromRGBO(255, 50, 0, 1),
      highlightColor: Color.fromRGBO(255, 100, 20, 1),
    ),
    'board_theme_green': BoardTheme(
      boardColor: Color.fromRGBO(210, 220, 200, 1),
      targetColor: Color.fromRGBO(50, 240, 120, 1),
      highlightColor: Color.fromRGBO(120, 240, 120, 1),
    ),
    'board_theme_grey': BoardTheme(
      boardColor: Color.fromRGBO(200, 200, 200, 1),
      targetColor: Color.fromRGBO(120, 120, 120, 1),
      highlightColor: Color.fromRGBO(120, 120, 120, 1),
    ),
  };
  
  SharedPreferences preferences;

  Future<void> initAsync() {
    return SharedPreferences.getInstance().then(_initialize);
  }

  void _initialize(SharedPreferences preferences) {
    this.preferences = preferences;

    _localeString = preferences.getString(LOCALE_KEY); // No default value: should use system's default
    _shouldDoubleTapConfirm = preferences.getBool(DOUBLE_TAP_CONFIRM_KEY) ?? true;
    _shouldHighlightLastStep = preferences.getBool(HIGHLIGHT_LAST_STEP_KEY) ?? true;
    _shouldHighlightWinningMoves = preferences.getBool(HIGHLIGHT_WINNING_MOVES_KEY) ?? true;
    _boardSize = preferences.getInt(BOARD_SIZE_KEY) ?? 15;
    _isDarkMode = preferences.getBool(APP_DARK_MODE_KEY) ?? false;
    _appAccentString = preferences.getString(APP_ACCENT_KEY) ?? APP_ACCENT.keys.first;
    _boardThemeString = preferences.getString(BOARD_THEME_KEY) ?? BOARD_THEME.keys.first;

    notifyListeners();
  }

  Locale get locale => SUPPORTED_LOCALES.firstWhere((l) => l.locale.toString() == _localeString, orElse: () => null)?.locale;

  String _localeString;

  String get localeString => _localeString;

  set localeString(String value) {
    _localeString = value;
    preferences.setString(LOCALE_KEY, value);
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
    brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    primarySwatch: APP_ACCENT[_appAccentString],
  );

  bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;

  set isDarkMode(bool value) {
    _isDarkMode = value;
    preferences.setBool(APP_DARK_MODE_KEY, value);
    notifyListeners();
  }

  String _appAccentString;

  String get appAccentString => _appAccentString;

  set appAccentString(String value) {
    _appAccentString = value;
    preferences.setString(APP_ACCENT_KEY, value);
    notifyListeners();
  }

  BoardTheme get boardTheme => BOARD_THEME[_boardThemeString];

  String _boardThemeString;

  String get boardThemeString => _boardThemeString;

  set boardThemeString(String value) {
    _boardThemeString = value;
    preferences.setString(BOARD_THEME_KEY, value);
    notifyListeners();
  }
}
