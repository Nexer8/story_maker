import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:mime/mime.dart';
import 'package:storymaker/utilities/constants/general_processing_values.dart';
import 'package:storymaker/services/clip_sample.dart';
import 'package:storymaker/utilities/duration_parser.dart';
import 'package:tuple/tuple.dart';

class FileProcessor extends ChangeNotifier {
  static int outputId = 0;
  static List<File> filesToRemove = List<File>();

  final FlutterFFmpeg flutterFFmpeg;
  final FlutterFFprobe flutterFFprobe;
  final FlutterFFmpegConfig flutterFFmpegConfig;
  final String rawDocumentPath;
  double meanVolume;
  double maxVolume;
  var sceneScores = List<double>();
  var sceneMoments = List<Duration>();

  FileProcessor(
      {this.rawDocumentPath,
      this.flutterFFmpeg,
      this.flutterFFprobe,
      this.flutterFFmpegConfig});

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
        "-y -i ${file.path} -ss ${startingPoint.toString()} -to ${endingPoint.toString()} -c copy $outputPath";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    if (rc == 0) {
      trimmedFile = File(outputPath);

      filesToRemove.add(trimmedFile);

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
    for (var file in filesToRemove) {
      file.deleteSync();
    }

    print('Cleaned files!');
    filesToRemove.clear();
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
      filesToRemove.add(extractedAudio);

      return extractedAudio;
    } else {
      return null;
    }
  }

  void logCallback(int level, String message) {
    if (message.contains(r'mean_volume')) {
      var pattern = RegExp(r'mean_volume:\s(-?[0-9]*(\.[0-9]*)?)');
      var match = pattern.firstMatch(message);

      meanVolume = double.parse(match.group(1));
    } else if (message.contains(r'max_volume')) {
      var pattern = RegExp(r'max_volume:\s(-?[0-9]*(\.[0-9]*)?)');
      var match = pattern.firstMatch(message);

      maxVolume = double.parse(match.group(1));
    } else if (message.contains(r'pts_time')) {
      var momentPattern = RegExp(r'pts_time:(-?[0-9]*(\.[0-9]*)?)');
      var match = momentPattern.firstMatch(message);

      Duration currentMoment = DurationParser.parseDuration(match.group(1));

      sceneMoments.add(currentMoment);
    } else if (message.contains(r'scene_score')) {
      var scorePattern = RegExp(r'scene_score=(-?[0-9]*(\.[0-9]*)?)');
      var match = scorePattern.firstMatch(message);

      double currentScore = double.parse(match.group(1));

      sceneScores.add(currentScore);
    }
  }

  Future<double> getAvgVolume(
      File file, Duration startingPoint, Duration endingPoint) async {
    if (!file.existsSync()) {
      return null;
    }

    flutterFFmpegConfig.enableLogCallback(this.logCallback);

    final String commandToExecute =
        "-y -ss ${startingPoint.toString()} -to ${endingPoint.toString()} -i ${file.path} -af 'volumedetect' -vn -sn -dn -f null /dev/null";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    flutterFFmpegConfig.logCallback = null;

    if (rc == 0) {
      return meanVolume;
    } else {
      return null;
    }
  }

  Future<double> getMaxVolume(File file) async {
    if (!file.existsSync()) {
      return null;
    }

    flutterFFmpegConfig.enableLogCallback(this.logCallback);

    final String commandToExecute =
        "-y -i ${file.path} -af 'volumedetect' -vn -sn -dn -f null /dev/null";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    flutterFFmpegConfig.logCallback = null;

    if (rc == 0) {
      return maxVolume;
    } else {
      return null;
    }
  }

  Future<Tuple2<List<double>, List<Duration>>> getBestSceneScoresAndMoments(
      File video) async {
    if (!video.existsSync()) {
      return null;
    }

    flutterFFmpegConfig.enableLogCallback(this.logCallback);

    final String commandToExecute =
        "-y -i ${video.path} -vf \"select = 'gte(scene,0)',metadata=print\" -f null /dev/null";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    flutterFFmpegConfig.logCallback = null;

    if (rc == 0) {
      return Tuple2(sceneScores, sceneMoments);
    } else {
      return null;
    }
  }

  Future<File> getBestMomentByAudio(File video, double samplingRate) async {
    if (video == null || await isSilent(video)) {
      return null;
    }

    var chunks = List<ClipSample>();

    Duration duration = await getDuration(video);
    var currentPoint = Duration();

    Duration step = Duration(
        microseconds: (duration.inMicroseconds / samplingRate).floor());

    while (currentPoint < duration) {
      Duration startingPoint =
          currentPoint + step <= duration ? currentPoint : duration - step;
      Duration endingPoint =
          currentPoint + step <= duration ? currentPoint + step : duration;

      chunks.add(ClipSample(
          file: video,
          startingPoint: startingPoint,
          endingPoint: endingPoint,
          meanVolume: await getAvgVolume(video, startingPoint, endingPoint)));

      currentPoint += step;
    }

    chunks.sort((b, a) => a.meanVolume.compareTo(b.meanVolume));

    File bestMoment =
        await trim(video, chunks.first.startingPoint, chunks.first.endingPoint);

    return bestMoment;
  }

  Future<File> getBestMomentByScene(File video, double samplingRate) async {
    if (video == null) {
      return null;
    }

    Duration duration = await getDuration(video);
    Duration step = Duration(
        microseconds: (duration.inMicroseconds / samplingRate).floor());

    Tuple2<List<double>, List<Duration>> bestSceneScoresAndMoments =
        await getBestSceneScoresAndMoments(video);

    if (bestSceneScoresAndMoments == null) {
      return null;
    }

    var bestMoments = List<ClipSample>();
    var currentPoint = Duration();
    int i = 0;

    while (currentPoint + step < duration &&
        i < bestSceneScoresAndMoments.item1.length) {
      double sceneValuesSum = 0;
      int counter = 0;
      Duration endingPoint = currentPoint;

      while (endingPoint < currentPoint + step &&
          i < bestSceneScoresAndMoments.item1.length - 1) {
        sceneValuesSum += bestSceneScoresAndMoments.item1.elementAt(i);
        counter++;

        i++;
        endingPoint = bestSceneScoresAndMoments.item2.elementAt(i);
      }

      bestMoments.add(ClipSample(
          startingPoint: currentPoint,
          endingPoint: currentPoint + step,
          bestSceneScore: (sceneValuesSum / counter.toDouble())));

      currentPoint = ((currentPoint + step) <= duration)
          ? currentPoint + step
          : duration - step;
    }

    bestMoments.sort((b, a) => a.bestSceneScore.compareTo(b.bestSceneScore));

    File bestMoment = await trim(
        video, bestMoments.first.startingPoint, bestMoments.first.endingPoint);

    return bestMoment;
  }
}
