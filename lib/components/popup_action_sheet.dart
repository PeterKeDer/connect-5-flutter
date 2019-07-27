import 'package:flutter/material.dart';

class PopupActionSheetItem {
  Widget leading;
  String text;
  VoidCallback onTap;

  PopupActionSheetItem({this.leading, this.text, this.onTap});
}

class PopupActionSheet extends StatelessWidget {
  final List<PopupActionSheetItem> items;

  PopupActionSheet(this.items);

  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => this
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) =>
        ListTile(
          leading: item.leading,
          title: Text(item.text),
          onTap: () {
            Navigator.pop(context);
            item.onTap();
          },
        )
      ).toList()
    );
  }
}
