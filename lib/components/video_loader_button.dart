import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/components/progress_dialog_window.dart';
import 'package:storymaker/services/general_story_processor.dart';
import 'package:storymaker/services/ui_data_provider.dart';
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
    final uiDataProvider = Provider.of<UIDataProvider>(context);

    return Expanded(
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
                left: 25.0, top: 10.0, right: 7.5, bottom: 10.0),
            height: double.infinity,
            width: double.infinity,
            child: MaterialButton(
              color: uiDataProvider.isGeneralProcessorOperational
                  ? kSecondaryColor
                  : kSecondaryDarkColor,
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
                    uiDataProvider.isGeneralProcessorOperational =
                        generalStoryProcessor.isOperational();
                  });
                }
              },
              child: Icon(
                Icons.video_library,
                color: kOnSecondaryColor,
              ),
            ),
          ),
          uiDataProvider.isGeneralProcessorOperational
              ? Positioned(
                  top: -10.0,
                  right: -23.0,
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        generalStoryProcessor.loadVideos(null);
                        uiDataProvider.isGeneralProcessorOperational =
                            generalStoryProcessor.isOperational();
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
