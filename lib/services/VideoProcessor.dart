import 'dart:io';

import 'package:storymaker/services/IFileProcessor.dart';

class VideoProcessor implements IFileProcessor {
  Future<List<File>> videos;

  File trimFromStart(File video, Duration duration) {
    File trimmedVideo;

    return trimmedVideo;
  } // TODO: To implement

  File trimFromEnd(File video, Duration duration) {
    File trimmedVideo;

    return trimmedVideo;
  } // TODO: To implement

  File joinVideos(List<File> videos) {
    File joinedVideo;

    return joinedVideo;
  } // TODO: To implement

  Duration getDuration(File video) {
    Duration duration;

    return duration;
  } // TODO: To implement

  File createVideoFromImage(File image, Duration duration) {
    File video;

    return video;
  } // TODO: To implement

  List<File> getFramesFromVideo(File video) {
    List<File> frames;

    return frames;
  } // TODO: To implement

  double calculateDifferenceBetweenFrames(File firstImage, File secondImage) {
    double diff;

    return diff;
  } // TODO: To implement
}
