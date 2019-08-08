import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SettingsOptionsType {
  locale, appAccent, boardTheme
}

class SettingsPage extends StatelessWidget {
  void _showOptionsPage(BuildContext context, SettingsOptionsType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final settingsManager = Provider.of<SettingsManager>(context);

          List<String> keys;
          List<String> texts;
          String title;
          String current;
          HandlerFunction<String> action;

          switch (type) {
            case SettingsOptionsType.locale:
              keys = SUPPORTED_LOCALES.map((locale) => locale.locale.toString()).toList();
              texts = SUPPORTED_LOCALES.map((locale) => locale.name).toList();
              title = localize(context, 'language');
              current = getLocaleString(Localizations.localeOf(context));
              action = (value) => settingsManager.localeString = value;
              break;
            case SettingsOptionsType.appAccent:
              keys = SettingsManager.APP_ACCENT.keys.toList();
              texts = keys.map((accent) => localize(context, accent)).toList();
              title = localize(context, 'accent');
              current = settingsManager.appAccentString;
              action = (value) => settingsManager.appAccentString = value;
              break;
            case SettingsOptionsType.boardTheme:
              keys = SettingsManager.BOARD_THEME.keys.toList();
              texts = keys.map((theme) => localize(context, theme)).toList();
              title = localize(context, 'board_theme');
              current = settingsManager.boardThemeString;
              action = (value) => settingsManager.boardThemeString = value;
              break;
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: ListView(
              children: List.generate(keys.length, (i) =>
                ListTile(
                  title: Text(texts[i]),
                  trailing: keys[i] == current ? Icon(Icons.check) : null,
                  onTap: () => action(keys[i]),
                )
              )
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
        title: Text(localize(context, 'settings')),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            subtitle: Text(localize(context, 'general')),
          ),
          ListTile(
            title: Text(localize(context, 'change_language')),
            onTap: () => _showOptionsPage(context, SettingsOptionsType.locale),
          ),
          ListTile(
            subtitle: Text(localize(context, 'game')),
          ),
          SwitchListTile(
            value: settingsManager.shouldDoubleTapConfirm,
            title: Text(localize(context, 'double_tap_to_confirm')),
            activeColor: primaryColor,
            onChanged: (value) => settingsManager.shouldDoubleTapConfirm = value,
          ),
          SwitchListTile(
            value: settingsManager.shouldHighlightLastStep,
            title: Text(localize(context, 'highlight_last_step')),
            activeColor: primaryColor,
            onChanged: (value) => settingsManager.shouldHighlightLastStep = value,
          ),
          SwitchListTile(
            value: settingsManager.shouldHighlightWinningMoves,
            title: Text(localize(context, 'highlight_winning_moves')),
            activeColor: primaryColor,
            onChanged: (value) => settingsManager.shouldHighlightWinningMoves = value,
          ),
          ListTile(
            title: Text(localize(context, 'board_size')),
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
            subtitle: Text(localize(context, 'appearance')),
          ),
          SwitchListTile(
            value: settingsManager.isDarkMode,
            title: Text(localize(context, 'dark_mode')),
            activeColor: primaryColor,
            onChanged: (value) => settingsManager.isDarkMode = value,
          ),
          ListTile(
            title: Text(localize(context, 'accent')),
            trailing: Text(localize(context, settingsManager.appAccentString)),
            onTap: () => _showOptionsPage(context, SettingsOptionsType.appAccent),
          ),
          ListTile(
            title: Text(localize(context, 'board_theme')),
            trailing: Text(localize(context, settingsManager.boardThemeString)),
            onTap: () => _showOptionsPage(context, SettingsOptionsType.boardTheme),
          )
        ],
      )
    );
  }
}
