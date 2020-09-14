import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class FileProcessor {
  static final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
  static final FlutterFFprobe flutterFFprobe = FlutterFFprobe();
  static int outputId = 0;
  Directory appDocumentDir;

  static bool isTimePeriodValid(Duration startingPoint, Duration endingPoint) =>
      startingPoint != null &&
      endingPoint != null &&
      !startingPoint.isNegative &&
      !endingPoint.isNegative &&
      endingPoint.compareTo(startingPoint) > 0;

  Future<File> trim(
      File file, Duration startingPoint, Duration endingPoint) async {
    if (!file.existsSync() || !isTimePeriodValid(startingPoint, endingPoint)) {
      return null;
    }

    final String rawDocumentPath = appDocumentDir.path;
    final String outputPath = rawDocumentPath + "/output${outputId++}.mp4";
    String commandToExecute =
        "-i ${file.path} -ss ${startingPoint.toString()} -t ${endingPoint.toString()} -c copy $outputPath";

    int rc = await FileProcessor.flutterFFmpeg.execute(commandToExecute);

    return rc == 0 ? File(outputPath) : null;
  }

  Future<Duration> getDuration(File file) async {
    if (!file.existsSync()) {
      return null;
    }

    Map info =
        await FileProcessor.flutterFFprobe.getMediaInformation(file.path);

    return Duration(milliseconds: info['duration']);
  }
}
