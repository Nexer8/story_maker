import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/services/video_processor.dart';
import 'package:storymaker/utilities/files_picker.dart';

class VideoLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final videoProcessor = Provider.of<VideoProcessor>(context);

    return Expanded(
      child: InkWell(
        onTap: () async {
          print('Video button was pressed');
          List<File> videos = await FilesPicker.pickVideosFromGallery();

          if (videos != null) {
            print('\nVideos: $videos');
            videoProcessor.videos = videos;
          }

          // setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(20.0),
          ),
          height: double.infinity,
          width: double.infinity,
          child: Icon(Icons.video_library),
        ),
      ),
    );
  }
}
