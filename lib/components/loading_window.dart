import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storymaker/utils/app_state_controller.dart';

class LoadingWindow extends StatelessWidget {
  final AppState appState;

  LoadingWindow({this.appState});

  @override
  Widget build(BuildContext context) {
    Widget widget;

    switch (appState) {
      case AppState.LoadingVideos:
        widget = Text('Loading Videos');
        break;
      case AppState.LoadingAudio:
        widget = Text('Loading Audio');
        break;
      case AppState.MakingStory:
        widget = Text('Making Story');
        break;
    }

    return widget;
  }
}
