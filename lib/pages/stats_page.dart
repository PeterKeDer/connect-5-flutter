import 'package:connect_5/components/dialogs.dart';
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
              onPressed: () => showAlertDialog(
                context: context,
                title: localize(context, 'clear_stats'),
                message: localize(context, 'clear_stats_alert_message'),
                confirmButtonTitle: localize(context, 'confirm'),
                confirmButtonAction: () => Provider.of<StatsManager>(context).clearStats(),
                showCancelButton: true,
              ),
            ),
          )
        ],
      ),
    );
  }
}
