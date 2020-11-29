import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storymaker/models/video_processing_data.dart';
import 'package:storymaker/services/video_processor.dart';
import 'package:storymaker/utils/constants/custom_exceptions.dart';
import 'package:storymaker/utils/constants/general_processing_values.dart';

class FlutterFFmpegMock extends Mock implements FlutterFFmpeg {}

class FlutterFFprobeMock extends Mock implements FlutterFFprobe {}

class FlutterFFmpegConfigMock extends Mock implements FlutterFFmpegConfig {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('VideoProcessor tests', () {
    final flutterFFmpegMock = FlutterFFmpegMock();
    final flutterFFprobeMock = FlutterFFprobeMock();
    final flutterFFmpegConfigMock = FlutterFFmpegConfigMock();

    final videoProcessor = VideoProcessor(
        flutterFFmpeg: flutterFFmpegMock,
        flutterFFprobe: flutterFFprobeMock,
        flutterFFmpegConfig: flutterFFmpegConfigMock,
        rawDocumentPath: 'test_resources');
    final firstVideo = File('test_resources/sample_video.mp4');
    final secondVideo = File('test_resources/sample_video.mp4');
    final firstVideoDuration = Duration(seconds: 30);
    final secondVideoDuration = Duration(seconds: 30);
    final finalDuration = Duration(seconds: 5);
    final List<VideoProcessingData> videosToProcess = [
      VideoProcessingData(
          video: firstVideo, originalDuration: firstVideoDuration),
      VideoProcessingData(
          video: secondVideo, originalDuration: secondVideoDuration)
    ];

    group('VideoProcessor joinVideos', () {
      test('ut_VideoProcessor_joinVideos_default', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        final regex = RegExp(r'^test_resources\/joined.\.mp4$');

        expect(
            regex.hasMatch(
                (await videoProcessor.joinVideos(firstVideo, secondVideo))
                    .path),
            true);
      });

      test('ut_VideoProcessor_joinVideos_invalid_videos', () async {
        expect(await videoProcessor.joinVideos(File(''), File('')), null);
      });

      test('ut_VideoProcessor_joinVideos_error_rc', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(-1));

        expect(await videoProcessor.joinVideos(firstVideo, secondVideo), null);
      });
    });

    group(
        'VideoProcessor loadVideosProcessingDataAndSetLongestAndTotalVideoDuration',
        () {
      test(
          'ut_VideoProcessor_loadVideosProcessingDataAndSetLongestAndTotalVideoDuration_default',
          () async {
        videoProcessor.videos = [firstVideo, secondVideo];
        videoProcessor.longestVideoDuration = firstVideoDuration;

        when(flutterFFprobeMock.getMediaInformation(firstVideo.path))
            .thenAnswer((_) async => Future<Map>.value(
                {'duration': firstVideoDuration.inMilliseconds}));
        when(flutterFFprobeMock.getMediaInformation(secondVideo.path))
            .thenAnswer((_) async => Future<Map>.value(
                {'duration': secondVideoDuration.inMilliseconds}));

        List<VideoProcessingData> result = await videoProcessor
            .loadVideosProcessingDataAndSetLongestAndTotalVideoDuration(
                finalDuration);

        for (int i = 0; i < result.length; i++) {
          expect(result[i].video.path, videosToProcess[i].video.path);
          expect(
              result[i].originalDuration, videosToProcess[i].originalDuration);
        }
      });

      test(
          'ut_VideoProcessor_loadVideosProcessingDataAndSetLongestAndTotalVideoDuration'
          '_VideosShorterThanFinalDurationException', () async {
        final finalDuration = Duration(minutes: 15);

        videoProcessor.videos = [firstVideo, secondVideo];
        videoProcessor.longestVideoDuration = firstVideoDuration;

        when(flutterFFprobeMock.getMediaInformation(firstVideo.path))
            .thenAnswer((_) async => Future<Map>.value(
                {'duration': firstVideoDuration.inMilliseconds}));
        when(flutterFFprobeMock.getMediaInformation(secondVideo.path))
            .thenAnswer((_) async => Future<Map>.value(
                {'duration': secondVideoDuration.inMilliseconds}));

        expect(
            () async => await videoProcessor
                .loadVideosProcessingDataAndSetLongestAndTotalVideoDuration(
                    finalDuration),
            throwsA(isInstanceOf<VideosShorterThanFinalDurationException>()));
      });

      test(
          'ut_VideoProcessor_loadVideosProcessingDataAndSetLongestAndTotalVideoDuration'
          '_VideosShorterThanMinimalDurationException', () async {
        final finalDuration = Duration(milliseconds: 1);
        videoProcessor.videos = [firstVideo, secondVideo];
        videoProcessor.longestVideoDuration = firstVideoDuration;

        when(flutterFFprobeMock.getMediaInformation(firstVideo.path))
            .thenAnswer((_) async => Future<Map>.value(
                {'duration': Duration(milliseconds: 1).inMilliseconds}));
        when(flutterFFprobeMock.getMediaInformation(secondVideo.path))
            .thenAnswer((_) async => Future<Map>.value(
                {'duration': Duration(milliseconds: 1).inMilliseconds}));

        expect(
            () async => await videoProcessor
                .loadVideosProcessingDataAndSetLongestAndTotalVideoDuration(
                    finalDuration),
            throwsA(isInstanceOf<VideosShorterThanMinimalDurationException>()));
      });
    });

    group('VideoProcessor createFinalVideo', () {
      const double maxVolume = 12;
      const double meanVolume = 12;

      test('ut_VideoProcessor_createFinalVideo_byAudio_default', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));
        when(flutterFFprobeMock.getMediaInformation(firstVideo.path))
            .thenAnswer((_) async => Future<Map>.value(
                {'duration': firstVideoDuration.inMilliseconds}));

        videoProcessor.maxVolume = maxVolume;
        videoProcessor.meanVolume = meanVolume;
        videoProcessor.videos = [firstVideo];
        videoProcessor.totalVideosDuration = firstVideoDuration;
        videoProcessor.longestVideoDuration = firstVideoDuration;

        final createdFinalVideo = await videoProcessor.createFinalVideo(
            finalDuration, ProcessingType.ByAudio);

        expect(createdFinalVideo.path, isNot(equals(null)));
      });

      test('ut_VideoProcessor_createFinalVideo_byScene_default', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));
        when(flutterFFprobeMock.getMediaInformation(firstVideo.path))
            .thenAnswer((_) async => Future<Map>.value(
                {'duration': firstVideoDuration.inMilliseconds}));

        videoProcessor.meanVolume = meanVolume;
        videoProcessor.videos = [firstVideo];
        videoProcessor.totalVideosDuration = firstVideoDuration;
        videoProcessor.longestVideoDuration = firstVideoDuration;

        final List<Duration> sceneMoments = [
          Duration(seconds: 20, milliseconds: 2)
        ];
        videoProcessor.sceneMoments = sceneMoments;
        final List<double> sceneScores = [0.9];
        videoProcessor.sceneScores = sceneScores;

        final createdFinalVideo = await videoProcessor.createFinalVideo(
            finalDuration, ProcessingType.ByScene);

        expect(createdFinalVideo.path, isNot(equals(null)));
      });

      test('ut_VideoProcessor_createFinalVideo_ExceededDurationException',
          () async {
        final exceededDuration = Duration(seconds: 16);

        expect(
            () async => await videoProcessor.createFinalVideo(
                exceededDuration, ProcessingType.ByScene),
            throwsA(isInstanceOf<ExceededDurationException>()));
      });
    });
  });
}
