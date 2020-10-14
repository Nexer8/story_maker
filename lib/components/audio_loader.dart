import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/components/progress_dialog_window.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/utils/files_picker.dart';

class AudioLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return Expanded(
      child: InkWell(
        onTap: () async {
          print('Audio button was pressed');
          File audio;

          ProgressDialog progressDialog =
              ProgressDialogWindow.getProgressDialog(context, 'Loading Audio');
          progressDialog.show();

          try {
            audio = await FilesPicker.pickAudioFromDevice();
          } catch (e) {
            progressDialog.hide();
            print(e);
          }

          progressDialog.hide();

          if (audio != null) {
            generalStoryProcessor.loadAudio(audio);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(20.0),
          ),
          height: double.infinity,
          width: double.infinity,
          child: Icon(Icons.audiotrack),
        ),
      ),
    );
  }
}
