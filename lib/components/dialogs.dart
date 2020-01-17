import 'package:connect_5/localization/localization.dart';
import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context, {String message, bool popDismissable = false}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async => popDismissable,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(message, style: Theme.of(context).textTheme.body1),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showAlertDialog({
  @required BuildContext context,
  String title,
  Widget titleWidget,
  String message,
  Widget content,
  String confirmButtonTitle,
  VoidCallback confirmButtonAction,
  bool hideDialogOnConfirm = true,
  bool showCancelButton = false,
  String cancelButtonTitle,
  VoidCallback cancelButtonAction,
  bool hideDialogOnCancel = true,
  bool barrierDismissible = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => AlertDialog(
      title: titleWidget ?? Text(title ?? ''),
      content: content ?? Text(message ?? ''),
      actions: <Widget>[
        if (showCancelButton)
          FlatButton(
            child: Text(cancelButtonTitle ?? localize(context, 'cancel')),
            onPressed: () {
              if (hideDialogOnCancel) {
                Navigator.pop(context);
              }
              if (cancelButtonAction != null) {
                cancelButtonAction();
              }
            },
          ),
        FlatButton(
          child: Text(confirmButtonTitle ?? localize(context, 'ok')),
          onPressed: () {
            if (hideDialogOnConfirm) {
              Navigator.pop(context);
            }
            if (confirmButtonAction != null) {
              confirmButtonAction();
            }
          },
        )
      ],
    ),
  );
}

void hideDialog(BuildContext context) {
  Navigator.pop(context);
}
