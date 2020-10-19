import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/components/progress_dialog_window.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/utils/constants/colors.dart';
import 'package:storymaker/utils/files_picker.dart';

class AudioLoaderButton extends StatefulWidget {
  @override
  _AudioLoaderButtonState createState() => _AudioLoaderButtonState();
}

class _AudioLoaderButtonState extends State<AudioLoaderButton> {
  @override
  Widget build(BuildContext context) {
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return Expanded(
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                left: 5.0, top: 10.0, right: 25.0, bottom: 10.0),
            height: double.infinity,
            width: double.infinity,
            child: MaterialButton(
              color: kSecondaryColor,
              onPressed: () async {
                File audio;

                ProgressDialog progressDialog =
                    ProgressDialogWindow.getProgressDialog(
                        context, 'Loading audio');
                await progressDialog.show();

                try {
                  audio = await FilesPicker.pickAudioFromDevice();
                } catch (e) {} finally {
                  await progressDialog.hide();
                }

                if (audio != null) {
                  setState(() {
                    generalStoryProcessor.loadAudio(audio);
                  });
                }
              },
              child: Icon(
                Icons.audiotrack,
                color: kOnSecondaryColor,
              ),
            ),
          ),
          generalStoryProcessor.isAudioLoaded()
              ? Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        generalStoryProcessor.loadAudio(null);
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: kOnSecondaryColor,
                      child: Icon(
                        Icons.check,
                        color: kSecondaryColor,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
