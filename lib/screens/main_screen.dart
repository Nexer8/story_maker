import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:storymaker/components/audio_loader_button.dart';
import 'package:storymaker/components/make_story_button.dart';
import 'package:storymaker/components/video_length_slider.dart';
import 'package:storymaker/components/processing_option_radio.dart';
import 'package:storymaker/components/video_loader_button.dart';
import 'package:storymaker/components/video_player.dart';
import 'package:storymaker/utils/constants/screen_ids.dart';

class MainScreen extends StatelessWidget {
  static const String id = mainScreenId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: Column(
          children: <Widget>[
            MyVideoPlayer(),
            SizedBox(
              height: 10.0,
            ),
            ProcessingOptionPicker(),
            VideoLengthSlider(),
            Container(
              height: 100.0,
              child: Row(
                children: <Widget>[
                  VideoLoaderButton(),
                  AudioLoaderButton(),
                ],
              ),
            ),
            MakeStoryButton(),
          ],
        ),
      ),
    );
  }
}
