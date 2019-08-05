import 'package:connect_5/components/popup_action_sheet.dart';
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
          ListTile(
            title: Text('Brightness'),
            trailing: Text(settingsManager.appBrightnessString),
            onTap: () => PopupActionSheet(
              title: 'Choose Brightness',
              items: SettingsManager.APP_BRIGHTNESS.keys.map((brightness) => 
                PopupActionSheetItem(
                  text: brightness,
                  trailing: brightness == settingsManager.appBrightnessString ? Icon(Icons.check) : null,
                  onTap: () => settingsManager.appBrightnessString = brightness,
                )
              ).toList(),
            ).show(context),
          ),
          ListTile(
            title: Text('Accent'),
            trailing: Text(settingsManager.appAccentString),
            onTap: () => PopupActionSheet(
              title: 'Choose Accent',
              items: SettingsManager.APP_ACCENT.keys.map((accent) => 
                PopupActionSheetItem(
                  text: accent,
                  trailing: accent == settingsManager.appAccentString ? Icon(Icons.check) : null,
                  onTap: () => settingsManager.appAccentString = accent,
                )
              ).toList(),
            ).show(context),
          ),
        ],
      )
    );
  }
}
