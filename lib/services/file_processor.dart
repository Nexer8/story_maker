import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:mime/mime.dart';

class FileProcessor extends ChangeNotifier {
  static final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
  static final FlutterFFprobe flutterFFprobe = FlutterFFprobe();
  static int outputId = 0;
  static List<File> createdFiles = List<File>();
  final String rawDocumentPath;

  FileProcessor({this.rawDocumentPath});

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

    File trimmedFile;
    String mimeType = lookupMimeType(file.path);
    String extension;

    if (mimeType.contains('audio')) {
      extension = '.mp3';
    } else if (mimeType.contains('video')) {
      extension = '.mp4';
    }

    final String outputPath =
        rawDocumentPath + "/trimmed${outputId++}" + extension;
    String commandToExecute =
        "-i ${file.path} -ss ${startingPoint.toString()} -t ${endingPoint.toString()} -c copy $outputPath";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    if (rc == 0) {
      trimmedFile = File(outputPath);
      createdFiles.add(trimmedFile);

      return trimmedFile;
    } else {
      return null;
    }
  }

  Future<Duration> getDuration(File file) async {
    if (!file.existsSync()) {
      return null;
    }

    Map info = await flutterFFprobe.getMediaInformation(file.path);

    if (info != null) {
      return Duration(milliseconds: info['duration']);
    } else {
      return null;
    }
  }

  static void fileCleanup() {
    for (var file in createdFiles) {
      file.delete();
    }
  }
}
