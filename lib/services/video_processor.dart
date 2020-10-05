import 'dart:io';

import 'package:export_video_frame/export_video_frame.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:storymaker/services/clip_sample.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:storymaker/services/video_processing_data.dart';
import 'package:storymaker/utilities/constants/error_codes.dart';
import 'package:storymaker/utilities/constants/general_processing_values.dart';

class VideoProcessor extends FileProcessor {
  List<File> _videos;
  File _finalVideo;
  var totalVideosDuration = Duration();
  var longestVideoDuration = Duration();
  double completeFactor = 0;

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
      String rawDocumentPath})
      : super(
            flutterFFmpeg: flutterFFmpeg,
            flutterFFprobe: flutterFFprobe,
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

      FileProcessor.createdFiles.add(joinedVideo);

      return joinedVideo;
    } else {
      return null;
    }
  }

  Future<int> getFrameRate(File video) async {
    if (!video.existsSync()) {
      return invalidFile;
    }

    int frameRate;
    Map info = await flutterFFprobe.getMediaInformation(video.path);

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

    List<File> frames = await ExportVideoFrame.exportImage(video.path,
        (await getDuration(video)).inSeconds * await getFrameRate(video), 1);
    FileProcessor.createdFiles.addAll(frames);

    return frames;
  }

  double calculateDifferenceBetweenFrames(File firstImage, File secondImage) {
    double diff;

    return diff;
  } // TODO: To implement

  Future<List<VideoProcessingData>> loadVideosProcessingData() async {
    var videosToProcess = List<VideoProcessingData>();

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

  Duration computeOneFractionValue(
      List<VideoProcessingData> videosToProcess, Duration finalDuration) {
    for (var videoData in videosToProcess) {
      videoData.normalizedTimeFraction =
          videoData.originalDuration.inMicroseconds.toDouble() /
              longestVideoDuration.inMicroseconds.toDouble();

      completeFactor += videoData.normalizedTimeFraction;
    }

    var oneFraction = Duration(
        microseconds:
            (finalDuration.inMicroseconds.toDouble() / completeFactor).round());

    return oneFraction;
  }

  Future<List<List<ClipSample>>> getBestMomentsForVideos(
      List<VideoProcessingData> videosToProcess, Duration oneFraction) async {
    var bestMomentsForVideos = List<List<ClipSample>>();

    for (var videoData in videosToProcess) {
      videoData.expectedDuration =
          oneFraction * videoData.normalizedTimeFraction;
      videoData.samplingRate = (videoData.originalDuration.inMicroseconds /
              videoData.expectedDuration.inMicroseconds)
          .round();

      bestMomentsForVideos.add(
          await getBestMomentsByAudio(videoData.video, videoData.samplingRate));
    }

    return bestMomentsForVideos;
  }

  Future<void> createFinalVideo(Duration finalDuration) async {
    if (finalDuration > maximalDuration) {
      print('Final Duration > Maximal Duration');
      return;
    }

    finalVideo = null;

    List<VideoProcessingData> videosProcessingData =
        await loadVideosProcessingData();

    if (videosProcessingData == null) {
      print('VideoProcessingData is null');
      return;
    }

    if (totalVideosDuration < finalDuration) {
      print('Too few files selected'); // TODO: To implement better
      return;
    }

    Duration oneFraction =
        computeOneFractionValue(videosProcessingData, finalDuration);

    List<List<ClipSample>> bestMomentsForVideos =
        await getBestMomentsForVideos(videosProcessingData, oneFraction);

    File videoToConcatenate = bestMomentsForVideos[0].first.file;

    for (int i = 1; i < bestMomentsForVideos.length; i++) {
      videoToConcatenate = await joinVideos(
          videoToConcatenate, bestMomentsForVideos[i].first.file);
    }

    finalVideo = videoToConcatenate;
  }
}
