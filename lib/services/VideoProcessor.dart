import 'dart:io';

import 'package:export_video_frame/export_video_frame.dart';
import 'package:storymaker/services/FileProcessor.dart';
import 'package:storymaker/utilities/constants/errorCodes.dart';

class VideoProcessor extends FileProcessor {
  static int outputId = 0;
  List<File> videos;
  File finalVideo;
  Directory appDocumentDir;

  VideoProcessor({this.videos, this.appDocumentDir});

  Future<File> joinVideos(File firstVideo, File secondVideo) async {
    if (!firstVideo.existsSync() || !secondVideo.existsSync()) {
      return null;
    }

    final String rawDocumentPath = appDocumentDir.path;
    final String outputPath = rawDocumentPath + "/output${outputId++}.mp4";
    final String commandToExecute =
        "-y -i ${firstVideo.path} -i ${secondVideo.path} -filter_complex '[0:0][1:0]concat=n=2:v=1:a=0[out]' -r ntsc-film -map '[out]' " +
            outputPath;

    int rc = await FileProcessor.flutterFFmpeg.execute(commandToExecute);

    return rc == 0 ? File(outputPath) : null;
  }

  Future<int> getFrameRate(File video) async {
    if (!video.existsSync()) {
      return invalidFile;
    }

    int frameRate;
    Map info =
        await FileProcessor.flutterFFprobe.getMediaInformation(video.path);

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

    return await ExportVideoFrame.exportImage(video.path,
        (await getDuration(video)).inSeconds * await getFrameRate(video), 1);
  }

  double calculateDifferenceBetweenFrames(File firstImage, File secondImage) {
    double diff;

    return diff;
  } // TODO: To implement
}
