import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'isAndroid.dart';

Future<void> showSimpleDialog(
  BuildContext context, {
  String title = "",
  required Widget content,
  String confirm = "Aceptar",
  String cancel = "Cancelar",
  Function? onConfirm,
  Function? onCancel,
}) async {
  if (onConfirm == null) {
    onConfirm = () {};
  }

  if (onCancel == null) {
    onCancel = () {};
  }

  if (isAndroid()) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content ?? Container(),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              onCancel!();
              Navigator.of(context).pop();
            },
            child: Text(
              cancel,
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              onConfirm!();
              Navigator.of(context).pop();
            },
            child: Text(confirm),
          ),
        ],
      ),
    );
  } else {
    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: content ?? Container(),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () {
              onCancel!();
              Navigator.of(context).pop();
            },
            isDestructiveAction: true,
            child: Text(cancel),
          ),
          CupertinoDialogAction(
            onPressed: () {
              onConfirm!();
              Navigator.of(context).pop();
            },
            child: Text(confirm),
          ),
        ],
      ),
    );
  }
}
