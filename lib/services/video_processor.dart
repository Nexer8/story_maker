import 'dart:io';

import 'package:export_video_frame/export_video_frame.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:storymaker/utilities/constants/error_codes.dart';

class VideoProcessor extends FileProcessor {
  List<File> _videos;
  File _finalVideo;

  List<File> get videos => _videos;

  set videos(List<File> videos) {
    _videos = videos;
    notifyListeners();
  }

  File get finalVideo => _finalVideo;

  set finalVideo(File finalVideo) {
    _finalVideo = finalVideo;
    notifyListeners();
  }

  VideoProcessor(
      {FlutterFFmpeg flutterFFmpeg,
      FlutterFFprobe flutterFFprobe,
      String rawDocumentPath})
      : super(
            flutterFFmpeg: flutterFFmpeg,
            flutterFFprobe: flutterFFprobe,
            rawDocumentPath: rawDocumentPath);

  Future<File> joinVideos(File firstVideo, File secondVideo) async {
    if (!firstVideo.existsSync() || !secondVideo.existsSync()) {
      return null;
    }

    File joinedVideo;
    final String outputPath =
        rawDocumentPath + "/output${FileProcessor.outputId++}.mp4";
    final String commandToExecute =
        "-i ${firstVideo.path} -i ${secondVideo.path} -filter_complex '[0:0][1:0]concat=n=2:v=1:a=0[out]' -r ntsc-film -map '[out]' " +
            outputPath;

    int rc = await flutterFFmpeg.execute(commandToExecute);

    if (rc == 0) {
      joinedVideo = File(outputPath);
      FileProcessor.createdFiles.add(joinedVideo);

      return joinedVideo;
    } else {
      return null;
    }
  }

  Future<int> getFrameRate(File video) async {
    if (!video.existsSync()) {
      return invalidFile;
    }

    int frameRate;
    Map info = await flutterFFprobe.getMediaInformation(video.path);

    if (info['streams'] != null) {
      final streamsInfoArray = info['streams'];

      if (streamsInfoArray.length > 0) {
        for (var streamsInfo in streamsInfoArray) {
          if (streamsInfo['averageFrameRate'] != null) {
            frameRate = double.parse(streamsInfo['averageFrameRate']).round();
          }
        }
      }
    }

    return frameRate;
  }

  Future<List<File>> getFramesFromVideo(File video) async {
    if (!video.existsSync()) {
      return null;
    }

    List<File> frames = await ExportVideoFrame.exportImage(video.path,
        (await getDuration(video)).inSeconds * await getFrameRate(video), 1);
    FileProcessor.createdFiles.addAll(frames);

    return frames;
  }

  double calculateDifferenceBetweenFrames(File firstImage, File secondImage) {
    double diff;

    return diff;
  } // TODO: To implement
}
