import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:storymaker/models/video_processing_data.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:storymaker/utils/constants/custom_exceptions.dart';
import 'package:storymaker/utils/constants/general_processing_values.dart';

class VideoProcessor extends FileProcessor {
  List<File> videos;
  Duration totalVideosDuration;
  Duration longestVideoDuration;

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
        "-y -i '${firstVideo.path}' -i '${secondVideo.path}' -filter_complex "
        "'[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[v][a]' -r ntsc-film -map "
        "'[v]' -map '[a]' $outputPath";

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
      loadVideosProcessingDataAndSetLongestAndTotalVideoDuration(
          Duration finalDuration) async {
    var videosToProcess = List<VideoProcessingData>();

    totalVideosDuration = Duration();
    longestVideoDuration = Duration();

    for (var video in videos) {
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

    if (totalVideosDuration < finalDuration) {
      throw VideosShorterThanFinalDurationException();
    }
    if (totalVideosDuration < minimalDuration) {
      throw VideosShorterThanMinimalDurationException();
    }

    return videosToProcess;
  }

  Future<File> createFinalVideo(
      Duration finalDuration, ProcessingType processingType) async {
    if (finalDuration > maximalDuration) {
      throw ExceededDurationException();
    }

    List<VideoProcessingData> videosProcessingData =
        await loadVideosProcessingDataAndSetLongestAndTotalVideoDuration(
            finalDuration);

    var bestMomentsForVideos = List<File>();
    File videoToConcatenate;

    for (var videoData in videosProcessingData) {
      videoData.expectedDuration = Duration(
          microseconds: ((videoData.originalDuration.inMicroseconds /
                      totalVideosDuration.inMicroseconds) *
                  finalDuration.inMicroseconds)
              .floor());

      switch (processingType) {
        case ProcessingType.ByAudio:
          {
            bestMomentsForVideos.add(await getBestMomentByAudio(
                videoData.video, videoData.expectedDuration));

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
                videoData.video, videoData.expectedDuration));

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
    return videoToConcatenate;
  }
}
