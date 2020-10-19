import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/components/neeko/lib/neeko.dart';
import 'package:storymaker/components/save_video_icon_button.dart';
import 'package:storymaker/components/share_video_icon_button.dart';
import 'package:storymaker/services/general_processor.dart';

class MyVideoPlayer extends StatefulWidget {
  @override
  VideoState createState() => VideoState();
}

class VideoState extends State<MyVideoPlayer> {
  VideoControllerWrapper videoControllerWrapper;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  }

  @override
  void dispose() {
    SystemChrome.restoreSystemUIOverlays();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return generalStoryProcessor.processedClip == null
        ? Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Image(
                image: AssetImage('assets/images/logo.png'),
              ),
            ),
          )
        : Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: NeekoPlayerWidget(
                videoControllerWrapper: videoControllerWrapper =
                    VideoControllerWrapper(
                  DataSource.file(generalStoryProcessor.processedClip),
                ),
                actions: <Widget>[
                  SaveVideoIconButton(
                      videoToSave: generalStoryProcessor.processedClip),
                  ShareVideoIconButton(
                      videoToShare: generalStoryProcessor.processedClip),
                ],
              ),
            ),
          );
  }
}
