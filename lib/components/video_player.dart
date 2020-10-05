import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatefulWidget {
  @override
  VideoState createState() => VideoState();
}

class VideoState extends State<MyVideoPlayer> {
  VideoPlayerController playerController;
  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      setState(() {});
    };
  }

  void loadVideo(File video) {
    print('Trying to load a video!!!');
    print('Processed clip path: ${video.path}');
    if (video.existsSync()) {
      playerController = VideoPlayerController.file(video)
        ..addListener(listener)
        ..setVolume(1.0)
        ..initialize();

      print('Video loaded!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return Expanded(
      child: InkWell(
        onTap: () {
          if (generalStoryProcessor != null) {
            loadVideo(generalStoryProcessor.processedClip);
            playerController.play();
          } else {
            print('No instance of generalStoryProcessor found!!!');
          }
        },
        child: Container(
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: playerController != null
                ? VideoPlayer(playerController)
                : Ink(
                    color: Colors.blueGrey,
                    child: Container(
                      height: 250.0,
                      width: double.infinity,
                      color: Colors.black,
                      child:
                          Icon(Icons.play_arrow, color: Colors.blueGrey[300]),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
