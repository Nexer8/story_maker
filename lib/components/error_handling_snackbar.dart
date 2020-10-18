import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storymaker/utils/constants/colors.dart';

class ErrorHandlingSnackbar {
  static const displayDuration = Duration(seconds: 4);

  static void show(Exception e, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: displayDuration,
      backgroundColor: kPrimaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        // side: BorderSide(color: Colors.blueGrey),
      ),
      content: Text(
        e.toString(),
        style: TextStyle(
            fontSize: 20.0,
            color: kOnPrimaryColor,
            fontWeight: FontWeight.normal),
      ),
      action: SnackBarAction(
        label: 'Close',
        textColor: kOnPrimaryColor,
        onPressed: () {
          Scaffold.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }
}
