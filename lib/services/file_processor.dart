import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:mime/mime.dart';
import 'package:storymaker/utilities/constants/general_processing_values.dart';
import 'package:storymaker/services/ClipSample.dart';

class FileProcessor extends ChangeNotifier {
  static int outputId = 0;
  static List<File> createdFiles = List<File>();

  final FlutterFFmpeg flutterFFmpeg;
  final FlutterFFprobe flutterFFprobe;
  final String rawDocumentPath;
  double avgVolume;
  double maxVolume;

  FileProcessor(
      {this.rawDocumentPath, this.flutterFFmpeg, this.flutterFFprobe});

  static bool isTimePeriodValid(Duration startingPoint, Duration endingPoint) =>
      startingPoint != null &&
      endingPoint != null &&
      !startingPoint.isNegative &&
      !endingPoint.isNegative &&
      endingPoint.compareTo(startingPoint) > 0;

  Future<bool> isSilent(File file) async =>
      await getMaxVolume(file) == digitalSilenceVolume;

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
        "-y -i ${file.path} -ss ${startingPoint.toString()} -t ${endingPoint.toString()} -c copy $outputPath";

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
      file.deleteSync();
    }

    print('Cleaned files!');
    createdFiles.clear();
  }

  Future<File> extractAudioFromVideo(File video) async {
    if (!video.existsSync()) {
      return null;
    }

    File extractedAudio;
    final String outputPath =
        rawDocumentPath + "/extractedAudio${outputId++}.mp3";
    final String commandToExecute =
        "-y -i ${video.path} -q:a 0 -map a $outputPath";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    if (rc == 0) {
      extractedAudio = File(outputPath);
      createdFiles.add(extractedAudio);

      return extractedAudio;
    } else {
      return null;
    }
  }

  void logCallback(int level, String message) {
    if (message.contains(r'mean_volume')) {
      RegExp pattern = RegExp(r'mean_volume:\s(-?[0-9]*(\.[0-9]*)?)');

      var match = pattern.firstMatch(message);
      avgVolume = double.parse(match.group(1));
    } else if (message.contains(r'max_volume')) {
      RegExp pattern = RegExp(r'max_volume:\s(-?[0-9]*(\.[0-9]*)?)');

      var match = pattern.firstMatch(message);
      maxVolume = double.parse(match.group(1));
    }
  }

  Future<double> getAvgVolume(File file) async {
    if (!file.existsSync()) {
      return null;
    }

    FlutterFFmpegConfig _flutterFFmpegConfig = FlutterFFmpegConfig();
    _flutterFFmpegConfig.enableLogCallback(this.logCallback);

    const int samplingRate = 1;
    final String commandToExecute =
        "-y -t $samplingRate -i ${file.path} -af 'volumedetect' -vn -sn -dn -f null /dev/null";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    _flutterFFmpegConfig.logCallback = null;

    if (rc == 0) {
      return avgVolume;
    } else {
      return null;
    }
  }

  Future<double> getMaxVolume(File file) async {
    if (!file.existsSync()) {
      return null;
    }

    FlutterFFmpegConfig _flutterFFmpegConfig = FlutterFFmpegConfig();
    _flutterFFmpegConfig.enableLogCallback(this.logCallback);

    const int samplingRate = 1;
    final String commandToExecute =
        "-y -t $samplingRate -i ${file.path} -af 'volumedetect' -vn -sn -dn -f null /dev/null";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    _flutterFFmpegConfig.logCallback = null;

    if (rc == 0) {
      return maxVolume;
    } else {
      return null;
    }
  }

  Future<List<ClipSample>> getBestMomentsByAudio(
      File video, int samplingRate) async {
    if (video == null || await isSilent(video)) {
      return null;
    }

    var chunks = List<ClipSample>();

    Duration duration = await getDuration(video);
    Duration currentPoint = Duration(milliseconds: 0);

    Duration step = Duration(
        milliseconds: (duration.inMilliseconds / samplingRate).round());

    while (currentPoint < duration) {
      chunks.add(ClipSample(
          file: await trim(video, currentPoint, currentPoint + step),
          startingPoint: currentPoint,
          endingPoint: currentPoint + step));
      currentPoint += step;
    }

    for (var chunk in chunks) {
      chunk.meanVolume = await getAvgVolume(chunk.file);
    }

    chunks.sort((b, a) => a.meanVolume.compareTo(b.meanVolume));

    return chunks;
  }
}
