import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:storymaker/components/audio_loader.dart';
import 'package:storymaker/components/make_story_button.dart';
import 'package:storymaker/components/length_picker.dart';
import 'package:storymaker/components/processing_option_picker.dart';
import 'package:storymaker/components/video_loader.dart';
import 'package:storymaker/components/video_player.dart';
import 'package:storymaker/utils/constants/screen_ids.dart';

class MainScreen extends StatelessWidget {
  static const String id = mainScreenId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: Column(
          children: <Widget>[
            MyVideoPlayer(),
            SizedBox(
              height: 10.0,
            ),
            ProcessingOptionPicker(),
            LengthPicker(),
            Container(
              height: 100.0,
              child: Row(
                children: <Widget>[
                  VideoLoader(),
                  SizedBox(
                    width: 10.0,
                  ),
                  AudioLoader(),
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
