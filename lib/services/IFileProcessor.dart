import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class IFileProcessor {
  static final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
  static final FlutterFFprobe flutterFFprobe = FlutterFFprobe();
  static int outputId = 0;
  Directory appDocumentDir;

  Future<File> trim(
      File file, Duration startingPoint, Duration endingPoint) async {
    final String rawDocumentPath = appDocumentDir.path;
    final String outputPath = rawDocumentPath + "/output${outputId++}.mp4";
    String commandToExecute =
        "-i ${file.path} -ss ${startingPoint.toString().replaceFirst(RegExp(r"\..*"), '')} -t ${endingPoint.toString().replaceFirst(RegExp(r"\..*"), '')} -c copy $outputPath";

    int rc = await IFileProcessor.flutterFFmpeg.execute(commandToExecute);

    return rc == 0 ? File(outputPath) : null;
  }

  Future<Duration> getDuration(File file) async {
    Map info =
        await IFileProcessor.flutterFFprobe.getMediaInformation(file.path);

    return Duration(milliseconds: info['duration']);
  }
}
