import 'package:connect_5/helpers/settings_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/pages/settings_options_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  void _showLanguageOptions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final settingsManager = Provider.of<SettingsManager>(context);

          return SettingsOptionsPage(
            title: localize(context, 'language'),
            texts: SUPPORTED_LOCALES.map((locale) => locale.name).toList(),
            values: SUPPORTED_LOCALES.map((locale) => locale.locale.toString()).toList(),
            current: settingsManager.localeString ?? getLocaleString(Localizations.localeOf(context)),
            action: (value) => settingsManager.localeString = value,
          );
        }
      )
    );
  }

  void _showAccentOptions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final settingsManager = Provider.of<SettingsManager>(context);
          final accents = SettingsManager.APP_ACCENT.keys;

          return SettingsOptionsPage(
            title: localize(context, 'accent'),
            texts: accents.map((accent) => localize(context, accent)).toList(),
            values: accents.toList(),
            current: settingsManager.appAccentString,
            action: (value) => settingsManager.appAccentString = value,
          );
        }
      )
    );
  }

  void _showBoardThemeOptions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final settingsManager = Provider.of<SettingsManager>(context);
          final themes = SettingsManager.BOARD_THEME.keys;

          return SettingsOptionsPage(
            title: localize(context, 'board_theme'),
            texts: themes.map((theme) => localize(context, theme)).toList(),
            current: settingsManager.boardThemeString,
            values: themes.toList(),
            action: (value) => settingsManager.boardThemeString = value,
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
            onTap: () => _showLanguageOptions(context),
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
            onTap: () => _showAccentOptions(context),
          ),
          ListTile(
            title: Text(localize(context, 'board_theme')),
            trailing: Text(localize(context, settingsManager.boardThemeString)),
            onTap: () => _showBoardThemeOptions(context),
          ),
          ListTile(
            subtitle: Text(localize(context, 'multiplayer')),
          ),
          ListTile(
            title: TextField(
              autocorrect: false,
              inputFormatters: [
                LengthLimitingTextInputFormatter(SettingsManager.MULTIPLAYER_NICKNAME_MAX_LENGTH),
              ],
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                labelText: localize(context, 'nickname'),
              ),
              controller: TextEditingController.fromValue(TextEditingValue(
                text: settingsManager.multiplayerNickname ?? '',
                selection: TextSelection.fromPosition(
                  TextPosition(offset: (settingsManager.multiplayerNickname ?? '').length)
                ),
              )),
              onSubmitted: (nickname) => settingsManager.multiplayerNickname = nickname,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
          ),
        ],
      )
    );
  }
}
