import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:storymaker/utils/constants/colors.dart';

class ProgressDialogWindow {
  static ProgressDialog getProgressDialog(
      BuildContext context, String message) {
    var progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      textDirection: TextDirection.rtl,
      isDismissible: false,
    );

    progressDialog.style(
      message: message,
      borderRadius: 10.0,
      backgroundColor: kPrimaryColor,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progressWidgetAlignment: Alignment.center,
      progressTextStyle: TextStyle(
          color: kOnPrimaryColor, fontSize: 13.0, fontWeight: FontWeight.w500),
      messageTextStyle: TextStyle(
          color: kOnPrimaryColor, fontSize: 19.0, fontWeight: FontWeight.w500),
    );

    return progressDialog;
  }
}
