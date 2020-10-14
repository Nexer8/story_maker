import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:storymaker/services/video_processing_data.dart';
import 'package:storymaker/utils/constants/general_processing_values.dart';

class VideoProcessor extends FileProcessor {
  List<File> _videos;
  File _finalVideo;
  Duration totalVideosDuration;
  Duration longestVideoDuration;
  double completeFactor;

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
      FlutterFFmpegConfig flutterFFmpegConfig,
      String rawDocumentPath})
      : super(
            flutterFFmpeg: flutterFFmpeg,
            flutterFFprobe: flutterFFprobe,
            flutterFFmpegConfig: flutterFFmpegConfig,
            rawDocumentPath: rawDocumentPath);

  Future<File> joinVideos(File firstVideo, File secondVideo) async {
    if (!firstVideo.existsSync() || !secondVideo.existsSync()) {
      return null;
    }

    File joinedVideo;
    final String outputPath =
        rawDocumentPath + "/joined${FileProcessor.outputId++}.mp4";
    final String commandToExecute =
        "-y -i ${firstVideo.path} -i ${secondVideo.path} -filter_complex '[0:0][1:0]concat=n=2:v=1:a=0[out]' -r ntsc-film -map '[out]' " +
            outputPath;

    int rc = await flutterFFmpeg.execute(commandToExecute);

    if (rc == 0) {
      joinedVideo = File(outputPath);

      FileProcessor.filesToRemove.add(joinedVideo);

      return joinedVideo;
    } else {
      return null;
    }
  }

  Future<List<VideoProcessingData>>
      loadVideosProcessingDataAndSetLongestAndTotalVideoDuration() async {
    var videosToProcess = List<VideoProcessingData>();

    totalVideosDuration = Duration();
    longestVideoDuration = Duration();

    for (var video in _videos) {
      Duration currentVideoDuration = await getDuration(video);

      if (currentVideoDuration == null) {
        return null;
      }

      if (longestVideoDuration < currentVideoDuration) {
        longestVideoDuration = currentVideoDuration;
      }

      totalVideosDuration += currentVideoDuration;
      videosToProcess.add(VideoProcessingData(
          video: video, originalDuration: currentVideoDuration));
    }

    return videosToProcess;
  }

  Duration computeOneFractionValueAndSetNormalizedTimeFraction(
      List<VideoProcessingData> videosToProcess, Duration finalDuration) {
    completeFactor = 0;

    for (var videoData in videosToProcess) {
      videoData.normalizedTimeFraction =
          videoData.originalDuration.inMicroseconds.toDouble() /
              longestVideoDuration.inMicroseconds.toDouble();

      completeFactor += videoData.normalizedTimeFraction;
    }

    var oneFraction = Duration(
        microseconds:
            (finalDuration.inMicroseconds.toDouble() / completeFactor).floor());

    return oneFraction;
  }

  Future<void> createFinalVideo(
      Duration finalDuration, ProcessingType processingType) async {
    if (finalDuration > maximalDuration) {
      print('Final Duration > Maximal Duration');
      return;
    }

    List<VideoProcessingData> videosProcessingData =
        await loadVideosProcessingDataAndSetLongestAndTotalVideoDuration();

    if (videosProcessingData == null) {
      print('VideoProcessingData is null');
      return;
    }

    if (totalVideosDuration < finalDuration) {
      print('Too few files selected'); // TODO: To implement better
      return;
    }
    if (totalVideosDuration < minimalDuration) {
      print('Too short files selected');
      return;
    }

    Duration oneFraction = computeOneFractionValueAndSetNormalizedTimeFraction(
        videosProcessingData, finalDuration);

    var bestMomentsForVideos = List<File>();
    File videoToConcatenate;

    for (var videoData in videosProcessingData) {
      videoData.expectedDuration =
          oneFraction * videoData.normalizedTimeFraction;
      videoData.samplingRate = videoData.originalDuration.inMicroseconds /
          videoData.expectedDuration.inMicroseconds;

      switch (processingType) {
        case ProcessingType.ByAudio:
          {
            bestMomentsForVideos.add(await getBestMomentByAudio(
                videoData.video, videoData.samplingRate));

            videoToConcatenate = bestMomentsForVideos.first;

            for (int i = 1; i < bestMomentsForVideos.length; i++) {
              videoToConcatenate =
                  await joinVideos(videoToConcatenate, bestMomentsForVideos[i]);
            }
            break;
          }

        case ProcessingType.ByScene:
          {
            bestMomentsForVideos.add(await getBestMomentByScene(
                videoData.video, videoData.samplingRate));

            videoToConcatenate = bestMomentsForVideos.first;

            for (int i = 1; i < bestMomentsForVideos.length; i++) {
              videoToConcatenate =
                  await joinVideos(videoToConcatenate, bestMomentsForVideos[i]);
            }
            break;
          }
      }
    }

    sceneScores.clear();
    sceneMoments.clear();
    finalVideo = videoToConcatenate;
  }
}
