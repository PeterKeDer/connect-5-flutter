import 'package:connect_5/helpers/stats_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statGroups = Provider.of<StatsManager>(context).statGroups;

    return Scaffold(
      appBar: AppBar(
        title: Text('Stats'),
      ),
      body: ListView(
        children: <Widget>[
          ...statGroups.expand((statGroup) => [
            ListTile(
              subtitle: Text(statGroup.title),
            ),
            ...statGroup.stats.map((stat) =>
              ListTile(
                title: Text(stat.title),
                trailing: Text(stat.value),
              )
            ).toList()
          ]).toList(),

          ListTile(
            title: RaisedButton(
              child: Text('Clear Stats'),
              onPressed: () => showDialog(
                context: context,
                child: AlertDialog(
                  title: Text('Clear Stats'),
                  content: Text('Are you sure you want to clear stats? They will be permanently deleted.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      textColor: Theme.of(context).colorScheme.primary,
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('Confirm'),
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
