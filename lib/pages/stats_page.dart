import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/helpers/stats_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statGroups = Provider.of<StatsManager>(context).statGroups;

    return Scaffold(
      appBar: AppBar(
        title: Text(localize(context, 'stats')),
      ),
      body: ListView(
        children: <Widget>[
          ...statGroups.expand((statGroup) => [
            ListTile(
              subtitle: Text(localize(context, statGroup.title)),
            ),
            ...statGroup.stats.map((stat) =>
              ListTile(
                title: Text(localize(context, stat.title)),
                trailing: Text(stat.value),
              )
            ).toList()
          ]).toList(),

          ListTile(
            title: RaisedButton(
              child: Text(localize(context, 'clear_stats')),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(localize(context, 'clear_stats')),
                  content: Text(localize(context, 'clear_stats_alert_message')),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(localize(context, 'cancel')),
                      textColor: Theme.of(context).colorScheme.primary,
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(localize(context, 'confirm')),
                      textColor: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        Provider.of<StatsManager>(context).clearStats();
                        Navigator.pop(context);
                      },
                    )
                  ],
                )
              )
            ),
          )
        ],
      ),
    );
  }
}
