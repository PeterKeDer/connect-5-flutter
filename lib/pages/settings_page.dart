import 'package:connect_5/helpers/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
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
            title: Text('Board Size: ${settingsManager.boardSize}'),
            subtitle: Slider(
              divisions: SettingsManager.MAX_BOARD_SIZE - SettingsManager.MIN_BOARD_SIZE,
              min: SettingsManager.MIN_BOARD_SIZE.toDouble(),
              max: SettingsManager.MAX_BOARD_SIZE.toDouble(),
              value: settingsManager.boardSize.toDouble(),
              onChanged: (value) => settingsManager.boardSize = value.round(),
            ),
          ),
          ListTile(
            subtitle: Text('Brightness'),
          ),
          ...SettingsManager.APP_BRIGHTNESS.keys.map((brightness) =>
            RadioListTile<String>(
              value: brightness,
              groupValue: settingsManager.appBrightnessString,
              title: Text(brightness),
              activeColor: primaryColor,
              onChanged: (brightness) => settingsManager.appBrightnessString = brightness,
            )
          ),
          ListTile(
            subtitle: Text('Accent'),
          ),
          ...SettingsManager.APP_ACCENT.keys.map((accent) =>
            RadioListTile<String>(
              value: accent,
              groupValue: settingsManager.appAccentString,
              title: Text(accent),
              activeColor: primaryColor,
              onChanged: (accent) => settingsManager.appAccentString = accent,
            )
          ),
        ],
      )
    );
  }
}
