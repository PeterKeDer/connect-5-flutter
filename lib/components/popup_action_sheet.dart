import 'package:flutter/material.dart';

class PopupActionSheetItem {
  Widget leading;
  String text;
  Widget trailing;
  VoidCallback onTap;
  bool dismissAfterTap;

  PopupActionSheetItem({this.leading, this.text, this.trailing, this.onTap, this.dismissAfterTap = true});
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
              style: TextStyle(color: Theme.of(context).textTheme.caption.color),
            ),
          ),

        ...items.map((item) =>
          ListTile(
            leading: item.leading,
            title: Text(item.text),
            trailing: item.trailing,
            onTap: () {
              if (item.dismissAfterTap) {
                Navigator.pop(context);
              }
              item.onTap();
            },
          )
        ).toList()
      ]
    );
  }
}
