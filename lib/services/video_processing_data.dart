import 'dart:io';

class VideoProcessingData {
  final File video;
  final Duration originalDuration;
  double normalizedTimeFraction;
  Duration expectedDuration;
  int samplingRate;

  VideoProcessingData({this.video, this.originalDuration});
}
