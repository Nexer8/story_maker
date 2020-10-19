import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/components/progress_dialog_window.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/utils/constants/colors.dart';
import 'package:storymaker/utils/files_picker.dart';

class VideoLoaderButton extends StatefulWidget {
  @override
  _VideoLoaderButtonState createState() => _VideoLoaderButtonState();
}

class _VideoLoaderButtonState extends State<VideoLoaderButton> {
  @override
  Widget build(BuildContext context) {
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return Expanded(
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
                left: 25.0, top: 10.0, right: 5.0, bottom: 10.0),
            height: double.infinity,
            width: double.infinity,
            child: MaterialButton(
              color: kSecondaryColor,
              onPressed: () async {
                List<File> videos;

                ProgressDialog progressDialog =
                    ProgressDialogWindow.getProgressDialog(
                        context, 'Loading video');
                await progressDialog.show();

                try {
                  videos = await FilesPicker.pickVideosFromGallery();
                } catch (e) {} finally {
                  await progressDialog.hide();
                }

                if (videos != null) {
                  setState(() {
                    generalStoryProcessor.loadVideos(videos);
                  });
                }
              },
              child: Icon(
                Icons.video_library,
                color: kOnSecondaryColor,
              ),
            ),
          ),
          generalStoryProcessor.getNumberOfLoadedVideos() != 0
              ? Positioned(
                  top: 0.0,
                  right: -20.0,
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        generalStoryProcessor.loadVideos(null);
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: kOnSecondaryColor,
                      child: Text(
                        generalStoryProcessor
                            .getNumberOfLoadedVideos()
                            .toString(),
                        style: TextStyle(color: kSecondaryColor),
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