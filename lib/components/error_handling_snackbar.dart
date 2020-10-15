import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorHandlingSnackbar {
  static const displayDuration = Duration(seconds: 4);

  static void show(Exception e, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: displayDuration,
      content: Text(e.toString()),
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.orange,
        onPressed: () {
          Scaffold.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }
}
