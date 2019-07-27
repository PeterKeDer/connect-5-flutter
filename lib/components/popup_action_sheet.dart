import 'package:flutter/material.dart';

class PopupActionSheetItem {
  Widget leading;
  String text;
  VoidCallback onTap;

  PopupActionSheetItem({this.leading, this.text, this.onTap});
}

class PopupActionSheet extends StatelessWidget {
  final String title;
  final List<PopupActionSheetItem> items;

  PopupActionSheet({this.title, @required this.items});

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
      children: [
        if (title != null && title.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              title,
            style: TextStyle(color: Colors.black45),
            ),
          ),

        ...items.map((item) =>
          ListTile(
            leading: item.leading,
            title: Text(item.text),
            onTap: () {
              Navigator.pop(context);
              item.onTap();
            },
          )
        ).toList()
      ]
    );
  }
}
