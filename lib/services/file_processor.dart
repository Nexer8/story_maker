import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:mime/mime.dart';

class FileProcessor {
  FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
  FlutterFFprobe flutterFFprobe = FlutterFFprobe();
  static int outputId = 0;
  final String rawDocumentPath;

  static final FileProcessor instance = FileProcessor(
      flutterFFmpeg: FlutterFFmpeg(), flutterFFprobe: FlutterFFprobe());

  FileProcessor(
      {this.flutterFFprobe, this.flutterFFmpeg, this.rawDocumentPath});

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

    String mimeType = lookupMimeType(file.path);
    String extension;

    if (mimeType.contains('audio')) {
      extension = '.mp3';
    } else if (mimeType.contains('video')) {
      extension = '.mp4';
    }

    final String outputPath =
        rawDocumentPath + "/output${outputId++}" + extension;
    String commandToExecute =
        "-i ${file.path} -ss ${startingPoint.toString()} -t ${endingPoint.toString()} -c copy $outputPath";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    return rc == 0 ? File(outputPath) : null;
  }

  Future<Duration> getDuration(File file) async {
    if (!file.existsSync()) {
      return null;
    }

    Map info = await flutterFFprobe.getMediaInformation(file.path);

    return Duration(milliseconds: info['duration']);
  }
}
