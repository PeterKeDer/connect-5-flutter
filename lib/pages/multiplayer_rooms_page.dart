import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiplayerRoomsPage extends StatelessWidget {
  static const double SPACING = 15;

  @override
  Widget build(BuildContext context) {
    final rooms = Provider.of<MultiplayerManager>(context).rooms ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(localize(context, 'rooms')),
      ),
      body: rooms.isNotEmpty
        ? ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(rooms[i].id),
          ),
        )
        : Center(
          child: Padding(
            padding: const EdgeInsets.all(SPACING),
            child: Text(
              localize(context, 'no_rooms_message'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.title
            ),
          )
        ),
    );
  }
}
