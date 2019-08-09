import 'package:connect_5/util.dart';
import 'package:flutter/material.dart';

class SettingsOptionsPage extends StatelessWidget {
  final String title;
  final List<String> texts;
  final String current;
  final List<String> values;
  final HandlerFunction<String> action;

  SettingsOptionsPage({this.title, this.texts, this.current, this.values, this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        children: List.generate(values.length, (i) =>
          ListTile(
            title: Text(texts[i]),
            trailing: values[i] == current ? Icon(Icons.check) : null,
            onTap: () => action(values[i]),
          )
        )
      ),
    );
  }
}
