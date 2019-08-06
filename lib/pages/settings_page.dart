import 'package:connect_5/components/board_painter.dart';
import 'package:connect_5/helpers/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SettingsOptionsType {
  appAccent, boardTheme
}

class SettingsPage extends StatelessWidget {
  void _showOptionsPage(BuildContext context, SettingsOptionsType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final settingsManager = Provider.of<SettingsManager>(context);

          Iterable<String> keys;
          String title;
          String current;
          HandlerFunction<String> action;

          switch (type) {
            case SettingsOptionsType.appAccent:
              keys = SettingsManager.APP_ACCENT.keys;
              title = 'Accent';
              current = settingsManager.appAccentString;
              action = (value) => settingsManager.appAccentString = value;
              break;
            case SettingsOptionsType.boardTheme:
              keys = SettingsManager.BOARD_THEME.keys;
              title = 'Board Theme';
              current = settingsManager.boardThemeString;
              action = (value) => settingsManager.boardThemeString = value;
              break;
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: ListView(
              children: keys.map((key) =>
                ListTile(
                  title: Text(key),
                  trailing: key == current ? Icon(Icons.check) : null,
                  onTap: () => action(key),
                )
              ).toList()
            ),
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsManager = Provider.of<SettingsManager>(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            subtitle: Text('General'),
          ),
          SwitchListTile(
            value: settingsManager.shouldDoubleTapConfirm,
            title: Text('Double Tap to Confirm'),
            activeColor: primaryColor,
            onChanged: (value) => settingsManager.shouldDoubleTapConfirm = value,
          ),
          SwitchListTile(
            value: settingsManager.shouldHighlightLastStep,
            title: Text('Highlight Last Step'),
            activeColor: primaryColor,
            onChanged: (value) => settingsManager.shouldHighlightLastStep = value,
          ),
          SwitchListTile(
            value: settingsManager.shouldHighlightWinningMoves,
            title: Text('Highlight Winning Moves'),
            activeColor: primaryColor,
            onChanged: (value) => settingsManager.shouldHighlightWinningMoves = value,
          ),
          ListTile(
            subtitle: Text('Game'),
          ),
          ListTile(
            title: Text('Board Size'),
            trailing: Text('${settingsManager.boardSize}'),
          ),
          Slider(
            divisions: SettingsManager.MAX_BOARD_SIZE - SettingsManager.MIN_BOARD_SIZE,
            min: SettingsManager.MIN_BOARD_SIZE.toDouble(),
            max: SettingsManager.MAX_BOARD_SIZE.toDouble(),
            value: settingsManager.boardSize.toDouble(),
            onChanged: (value) => settingsManager.boardSize = value.round(),
          ),
          ListTile(
            subtitle: Text('Appearance'),
          ),
          SwitchListTile(
            value: settingsManager.isDarkMode,
            title: Text('Dark Mode'),
            activeColor: primaryColor,
            onChanged: (value) => settingsManager.isDarkMode = value,
          ),
          ListTile(
            title: Text('Accent'),
            trailing: Text(settingsManager.appAccentString),
            onTap: () => _showOptionsPage(context, SettingsOptionsType.appAccent),
          ),
          ListTile(
            title: Text('Board Theme'),
            trailing: Text(settingsManager.boardThemeString),
            onTap: () => _showOptionsPage(context, SettingsOptionsType.boardTheme),
          )
        ],
      )
    );
  }
}
