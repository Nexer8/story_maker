import 'dart:io';

class VideoProcessingData {
  final File video;
  final Duration originalDuration;
  Duration expectedDuration;

  VideoProcessingData({this.video, this.originalDuration});
}
