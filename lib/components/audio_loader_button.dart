import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/components/progress_dialog_window.dart';
import 'package:storymaker/services/general_story_processor.dart';
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
                left: 7.5, top: 10.0, right: 25.0, bottom: 10.0),
            height: double.infinity,
            width: double.infinity,
            child: MaterialButton(
              color: generalStoryProcessor.isAudioLoaded()
                  ? kSecondaryColor
                  : kSecondaryDarkColor,
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
                  top: -10.0,
                  right: -8.0,
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        generalStoryProcessor.loadAudio(null);
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: kOnPrimaryColor,
                      child: Icon(
                        Icons.clear,
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
