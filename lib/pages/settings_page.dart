import 'package:connect_5/helpers/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsManager = Provider.of<SettingsManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: settingsManager.isLoaded
        ? ListView(
            children: <Widget>[
              ListTile(
                subtitle: Text('General'),
              ),
              SwitchListTile.adaptive(
                value: settingsManager.shouldDoubleTapConfirm,
                title: Text('Double Tap to Confirm'),
                onChanged: (value) => settingsManager.shouldDoubleTapConfirm = value,
              ),
              SwitchListTile.adaptive(
                value: settingsManager.shouldHighlightLastStep,
                title: Text('Highlight Last Step'),
                onChanged: (value) => settingsManager.shouldHighlightLastStep = value,
              ),
              SwitchListTile.adaptive(
                value: settingsManager.shouldHighlightWinningMoves,
                title: Text('Highlight Winning Moves'),
                onChanged: (value) => settingsManager.shouldHighlightWinningMoves = value,
              ),
            ],
          )
        : Center(
            child: Text('Loading Settings...'),
          )
    );
  }
}
