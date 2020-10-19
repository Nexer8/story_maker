import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storymaker/components/progress_dialog_window.dart';

class SaveVideoIconButton extends StatelessWidget {
  final File videoToSave;

  SaveVideoIconButton({this.videoToSave});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.get_app,
      ),
      onPressed: () async {
        ProgressDialog progressDialog = ProgressDialogWindow.getProgressDialog(
            context, 'Saving video to the gallery');
        await progressDialog.show();

        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        int savedFileId = (sharedPreferences.getInt('savedFileId') ?? 0) + 1;
        await sharedPreferences.setInt('savedFileId', savedFileId);

        String newPath = (await getApplicationDocumentsDirectory()).path +
            '/story' +
            savedFileId.toString() +
            '.mp4';
        await videoToSave.copy(newPath);

        await GallerySaver.saveVideo(newPath);
        File(newPath).deleteSync();

        await progressDialog.hide();
      },
    );
  }
}
