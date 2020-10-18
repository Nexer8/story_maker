import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:progress_dialog/progress_dialog.dart';
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

        await GallerySaver.saveVideo(videoToSave.path);

        await progressDialog.hide();
      },
    );
  }
}
