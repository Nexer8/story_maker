import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:mime/mime.dart';
import 'package:storymaker/models/clip_sample.dart';
import 'package:storymaker/utils/constants/custom_exceptions.dart';
import 'package:storymaker/utils/constants/general_processing_values.dart';
import 'package:storymaker/utils/duration_parser.dart';
import 'package:tuple/tuple.dart';

class FileProcessor {
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
      throw InvalidFileException();
    }

    File trimmedFile;
    String mimeType = lookupMimeType(file.path);
    String extension;

    if (mimeType == null || mimeType.contains('audio')) {
      extension = '.mp3';
    } else if (mimeType.contains('video')) {
      extension = '.mp4';
    }

    final String outputPath =
        rawDocumentPath + "/trimmed${outputId++}" + extension;
    String commandToExecute =
        "-y -i '${file.path}' -ss ${startingPoint.toString()} -to "
        "${endingPoint.toString()} -c copy $outputPath";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    if (rc == 0) {
      trimmedFile = File(outputPath);

      filesToRemove.add(trimmedFile);

      return trimmedFile;
    } else {
      throw UnknownException();
    }
  }

  Future<Duration> getDuration(File file) async {
    if (!file.existsSync()) {
      throw InvalidFileException();
    }

    Map info = await flutterFFprobe.getMediaInformation(file.path);

    if (info != null) {
      return Duration(milliseconds: info['duration']);
    } else {
      throw UnknownException();
    }
  }

  static void fileCleanup() {
    for (var file in filesToRemove) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    filesToRemove.clear();
  }

  Future<File> extractAudioFromVideo(File video) async {
    if (!video.existsSync()) {
      throw InvalidFileException();
    }

    File extractedAudio;
    final String outputPath =
        rawDocumentPath + "/extractedAudio${outputId++}.mp3";
    final String commandToExecute =
        "-y -i '${video.path}' -codec:a libmp3lame -qscale:a 2 $outputPath";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    if (rc == 0) {
      extractedAudio = File(outputPath);
      filesToRemove.add(extractedAudio);

      return extractedAudio;
    } else {
      throw UnknownException();
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
      throw InvalidFileException();
    }

    flutterFFmpegConfig.enableLogCallback(this.logCallback);

    final String commandToExecute =
        "-y -ss ${startingPoint.toString()} -to ${endingPoint.toString()} "
        "-i '${file.path}' -af 'volumedetect' -vn -sn -dn -f null /dev/null";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    flutterFFmpegConfig.logCallback = null;

    if (rc == 0) {
      return meanVolume;
    } else {
      throw UnknownException();
    }
  }

  Future<double> getMaxVolume(File file) async {
    if (!file.existsSync()) {
      throw InvalidFileException();
    }

    flutterFFmpegConfig.enableLogCallback(this.logCallback);

    final String commandToExecute =
        "-y -i '${file.path}' -af 'volumedetect' -vn -sn -dn -f null /dev/null";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    flutterFFmpegConfig.logCallback = null;

    if (rc == 0) {
      return maxVolume;
    } else {
      throw UnknownException();
    }
  }

  Future<Tuple2<List<double>, List<Duration>>> getMeanSceneScoresAndMoments(
      File video) async {
    if (!video.existsSync()) {
      throw InvalidVideoFileException();
    }

    flutterFFmpegConfig.enableLogCallback(this.logCallback);

    final String commandToExecute =
        "-y -i '${video.path}' -vf \"select = 'gte(scene,0)',metadata=print\""
        " -f null /dev/null";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    flutterFFmpegConfig.logCallback = null;

    if (rc == 0) {
      return Tuple2(sceneScores, sceneMoments);
    } else {
      throw UnknownException();
    }
  }

  Future<File> getBestMomentByAudio(File video, Duration step) async {
    if (video == null || await isSilent(video)) {
      throw NoAudioException();
    }

    var chunks = List<ClipSample>();

    Duration duration = await getDuration(video);
    var currentPoint = Duration();

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

  Future<File> getBestMomentByScene(File video, Duration step) async {
    if (video == null) {
      throw InvalidVideoFileException();
    }

    Duration duration = await getDuration(video);

    Tuple2<List<double>, List<Duration>> bestSceneScoresAndMoments =
        await getMeanSceneScoresAndMoments(video);

    if (bestSceneScoresAndMoments == null) {
      return null;
    }

    var bestMoments = List<ClipSample>();
    var currentPoint = Duration();
    int i = 0;

    while (currentPoint + step <= duration &&
        i < bestSceneScoresAndMoments.item1.length) {
      double sceneValuesSum = 0;
      int counter = 0;
      Duration endingPoint = currentPoint;

      while (endingPoint <= currentPoint + step &&
          i < bestSceneScoresAndMoments.item1.length - 1) {
        sceneValuesSum += bestSceneScoresAndMoments.item1.elementAt(i);
        counter++;

        i++;
        endingPoint = bestSceneScoresAndMoments.item2.elementAt(i);
      }

      bestMoments.add(ClipSample(
          startingPoint: currentPoint,
          endingPoint: currentPoint + step,
          meanSceneScore: (sceneValuesSum / counter.toDouble())));

      currentPoint = ((currentPoint + step) <= duration)
          ? currentPoint + step
          : duration - step;
    }

    bestMoments.sort((b, a) => a.meanSceneScore.compareTo(b.meanSceneScore));

    File bestMoment = await trim(
        video, bestMoments.first.startingPoint, bestMoments.first.endingPoint);

    return bestMoment;
  }
}
