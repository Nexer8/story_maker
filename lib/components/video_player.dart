import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neeko/neeko.dart';
import 'package:provider/provider.dart';
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

    return Expanded(
      child: Column(children: <Widget>[
        Expanded(
          child: Container(),
        ),
        if (generalStoryProcessor.processedClip == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              child: Image.asset(
                'assets/images/logo.png',
                width: 180,
              ),
              // child: SvgPicture.asset(
              //   'assets/images/logo.svg',
              //   matchTextDirection: true,
              //   width: 180,
              // ),
            ),
          )
        else
          Container(
            child: NeekoPlayerWidget(
              videoControllerWrapper: videoControllerWrapper =
                  VideoControllerWrapper(
                      DataSource.file(generalStoryProcessor.processedClip)),
              actions: <Widget>[
                SaveVideoIconButton(
                    videoToSave: generalStoryProcessor.processedClip),
                ShareVideoIconButton(
                    videoToShare: generalStoryProcessor.processedClip),
              ],
            ),
          ),
        Expanded(
          child: Container(),
        ),
      ]),
    );
  }
}
