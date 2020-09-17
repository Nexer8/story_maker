import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/components/audio_loader.dart';
import 'package:storymaker/components/make_story_button.dart';
import 'package:storymaker/components/video_loader.dart';
import 'package:storymaker/components/video_player.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/utilities/constants/screen_ids.dart';

class MainScreen extends StatelessWidget {
  static const String id = mainScreenId;

  @override
  Widget build(BuildContext context) {
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: Column(
          children: <Widget>[
            MyVideoPlayer(generalStoryProcessor),
            SizedBox(
              height: 10.0,
            ),
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
