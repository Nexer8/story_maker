import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:mockito/mockito.dart';
import 'package:tuple/tuple.dart';

class FlutterFFmpegMock extends Mock implements FlutterFFmpeg {}

class FlutterFFprobeMock extends Mock implements FlutterFFprobe {}

class FlutterFFmpegConfigMock extends Mock implements FlutterFFmpegConfig {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('FileProcessor tests', () {
    final flutterFFmpegMock = FlutterFFmpegMock();
    final flutterFFprobeMock = FlutterFFprobeMock();
    final flutterFFmpegConfigMock = FlutterFFmpegConfigMock();

    final fileProcessor = FileProcessor(
        flutterFFmpeg: flutterFFmpegMock,
        flutterFFprobe: flutterFFprobeMock,
        flutterFFmpegConfig: flutterFFmpegConfigMock,
        rawDocumentPath: 'test_resources');
    final audioFile = File('test_resources/sample_audio.mp3');
    final videoFile = File('test_resources/sample_video.mp4');
    final audioDuration = Duration(seconds: 27);
    final videoDuration = Duration(seconds: 20);

    group('FileProcessor trim', () {
      Duration startingPoint = Duration(seconds: 0);
      Duration endingPoint = startingPoint + Duration(seconds: 1);

      test('ut_FileProcessor_trim_audio_default', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        final regex = RegExp(r'^test_resources\/trimmed.\.mp3$');

        expect(
            regex.hasMatch((await fileProcessor.trim(
                    audioFile, startingPoint, endingPoint))
                .path),
            true);
      });

      test('ut_FileProcessor_trim_video_default', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        final regex = RegExp(r'^test_resources\/trimmed.\.mp4$');

        expect(
            regex.hasMatch((await fileProcessor.trim(
                    videoFile, startingPoint, endingPoint))
                .path),
            true);
      });
    });

    group('FileProcessor getDuration', () {
      test('ut_FileProcessor_getDuration_audio_default', () async {
        when(flutterFFprobeMock.getMediaInformation(audioFile.path)).thenAnswer(
            (_) async =>
                Future<Map>.value({'duration': audioDuration.inMilliseconds}));

        expect(await fileProcessor.getDuration(audioFile), audioDuration);
      });

      test('ut_FileProcessor_getDuration_video_default', () async {
        when(flutterFFprobeMock.getMediaInformation(videoFile.path)).thenAnswer(
            (_) async =>
                Future<Map>.value({'duration': videoDuration.inMilliseconds}));

        expect(await fileProcessor.getDuration(videoFile), videoDuration);
      });
    });

    group('FileProcessor logCallback', () {
      const String meanVolumeString = 'mean_volume: 12.7';
      const double meanVolume = 12.7;

      const String maxVolumeString = 'max_volume: 42';
      const double maxVolume = 42;

      const String currentMomentString = 'pts_time:20.2';
      final List<Duration> sceneMoments = [
        Duration(seconds: 20, milliseconds: 2)
      ];

      const String sceneScoreString = 'scene_score=0.9';
      final List<double> sceneScores = [0.9];

      test('ut_FileProcessor_logCallback_mean_volume_default', () {
        fileProcessor.logCallback(1, meanVolumeString);
        expect(fileProcessor.meanVolume, meanVolume);
      });

      test('ut_FileProcessor_logCallback_max_volume_default', () {
        fileProcessor.logCallback(1, maxVolumeString);
        expect(fileProcessor.maxVolume, maxVolume);
      });

      test('ut_FileProcessor_logCallback_pts_time_default', () {
        fileProcessor.logCallback(1, currentMomentString);
        expect(fileProcessor.sceneMoments, sceneMoments);
      });

      test('ut_FileProcessor_logCallback_max_volume_default', () {
        fileProcessor.logCallback(1, sceneScoreString);
        expect(fileProcessor.sceneScores, sceneScores);
      });
    });

    group('FileProcessor getAvgVolume', () {
      test('ut_FileProcessor_getAvgVolume_default', () async {
        final startingPoint = Duration(seconds: 0);
        final endingPoint = startingPoint + Duration(seconds: 1);
        const double meanVolume = 12;
        fileProcessor.meanVolume = meanVolume;

        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        expect(
            await fileProcessor.getAvgVolume(
                videoFile, startingPoint, endingPoint),
            meanVolume);

        verify(flutterFFmpegConfigMock
                .enableLogCallback(fileProcessor.logCallback))
            .called(1);
      });
    });

    group('FileProcessor getMaxVolume', () {
      test('ut_FileProcessor_getMaxVolume_default', () async {
        const double maxVolume = 12;
        fileProcessor.maxVolume = maxVolume;

        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        expect(await fileProcessor.getMaxVolume(videoFile), maxVolume);

        verify(flutterFFmpegConfigMock
                .enableLogCallback(fileProcessor.logCallback))
            .called(1);
      });
    });

    group('FileProcessor getBestSceneScoresAndMoments', () {
      test('ut_FileProcessor_getBestSceneScoresAndMoments_default', () async {
        final List<Duration> sceneMoments = [
          Duration(seconds: 20, milliseconds: 2)
        ];
        fileProcessor.sceneMoments = sceneMoments;

        final List<double> sceneScores = [0.9];
        fileProcessor.sceneScores = sceneScores;

        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        expect(await fileProcessor.getBestSceneScoresAndMoments(videoFile),
            Tuple2(sceneScores, sceneMoments));

        verify(flutterFFmpegConfigMock
                .enableLogCallback(fileProcessor.logCallback))
            .called(1);
      });
    });
  });
}
