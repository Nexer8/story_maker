import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:mockito/mockito.dart';
import 'package:storymaker/utils/constants/custom_exceptions.dart';
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

      test('ut_FileProcessor_trim_InvalidFileException', () async {
        expect(
            () async =>
                await fileProcessor.trim(File(''), startingPoint, endingPoint),
            throwsA(isInstanceOf<InvalidFileException>()));
      });

      test('ut_FileProcessor_trim_UnknownException', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(-1));

        expect(
            () async =>
                await fileProcessor.trim(videoFile, startingPoint, endingPoint),
            throwsA(isInstanceOf<UnknownException>()));
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

      test('ut_FileProcessor_getDuration_InvalidFileException', () {
        expect(() async => await fileProcessor.getDuration(File('')),
            throwsA(isInstanceOf<InvalidFileException>()));
      });

      test('ut_FileProcessor_getDuration_UnknownException', () {
        when(flutterFFprobeMock.getMediaInformation(videoFile.path))
            .thenAnswer((_) async => Future<Map>.value(null));

        expect(() async => await fileProcessor.getDuration(videoFile),
            throwsA(isInstanceOf<UnknownException>()));
      });
    });

    group('FileProcessor extractAudioFromVideo', () {
      test('ut_FileProcessor_extractAudioFromVideo_default', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        final regex = RegExp(r'^test_resources\/extractedAudio.\.mp3$');

        expect(
            regex.hasMatch(
                (await fileProcessor.extractAudioFromVideo(videoFile)).path),
            true);
      });

      test('ut_FileProcessor_extractAudioFromVideo_InvalidFileException',
          () async {
        expect(() async => await fileProcessor.extractAudioFromVideo(File('')),
            throwsA(isInstanceOf<InvalidFileException>()));
      });

      test('ut_FileProcessor_extractAudioFromVideo_UnknownException', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(-1));

        expect(() async => await fileProcessor.extractAudioFromVideo(videoFile),
            throwsA(isInstanceOf<UnknownException>()));
      });
    });

    group('FileProcessor logCallback', () {
      const String meanVolumeString = 'mean_volume: 12.7';
      const double meanVolume = 12.7;

      const String maxVolumeString = 'max_volume: 42';
      const double maxVolume = 42;

      const String currentMomentString = 'pts_time:20.2';
      final List<Duration> sceneMoments = [
        Duration(seconds: 20, milliseconds: 200)
      ];

      const String sceneScoreString = 'scene_score=0.9';
      final List<double> sceneScores = [0.9];

      tearDown(() {
        fileProcessor.sceneMoments.clear();
        fileProcessor.sceneScores.clear();
      });

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
      final startingPoint = Duration(seconds: 0);
      final endingPoint = startingPoint + Duration(seconds: 1);

      test('ut_FileProcessor_getAvgVolume_default', () async {
        const double meanVolume = 12;
        fileProcessor.meanVolume = meanVolume;

        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        expect(
            await fileProcessor.getAvgVolume(
                videoFile, startingPoint, endingPoint),
            meanVolume);
      });

      test('ut_FileProcessor_getAvgVolume_InvalidFileException', () async {
        expect(
            () async => await fileProcessor.getAvgVolume(
                File(''), startingPoint, endingPoint),
            throwsA(isInstanceOf<InvalidFileException>()));
      });

      test('ut_FileProcessor_getAvgVolume_UnknownException', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(-1));

        expect(
            () async => await fileProcessor.getAvgVolume(
                videoFile, startingPoint, endingPoint),
            throwsA(isInstanceOf<UnknownException>()));
      });
    });

    group('FileProcessor getMaxVolume', () {
      test('ut_FileProcessor_getMaxVolume_default', () async {
        const double maxVolume = 12;
        fileProcessor.maxVolume = maxVolume;

        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        expect(await fileProcessor.getMaxVolume(videoFile), maxVolume);
      });

      test('ut_FileProcessor_getMaxVolume_InvalidFileException', () async {
        expect(() async => await fileProcessor.getMaxVolume(File('')),
            throwsA(isInstanceOf<InvalidFileException>()));
      });

      test('ut_FileProcessor_getMaxVolume_UnknownException', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(-1));

        expect(() async => await fileProcessor.getMaxVolume(videoFile),
            throwsA(isInstanceOf<UnknownException>()));
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
      });

      test('ut_FileProcessor_getBestSceneScoresAndMoments_InvalidFileException',
          () async {
        expect(
            () async =>
                await fileProcessor.getBestSceneScoresAndMoments(File('')),
            throwsException);
      });

      test('ut_FileProcessor_getBestSceneScoresAndMoments_UnknownException',
          () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(-1));

        expect(
            () async =>
                await fileProcessor.getBestSceneScoresAndMoments(videoFile),
            throwsA(isInstanceOf<UnknownException>()));
      });
    });

    group('FileProcessor getBestMomentByAudio', () {
      const double samplingRate = 12;

      test('ut_FileProcessor_getBestMomentByAudio_default', () async {
        const double maxVolume = 12;
        fileProcessor.maxVolume = maxVolume;
        const double meanVolume = 12;
        fileProcessor.meanVolume = meanVolume;

        when(flutterFFprobeMock.getMediaInformation(videoFile.path)).thenAnswer(
            (_) async =>
                Future<Map>.value({'duration': videoDuration.inMilliseconds}));

        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        final regex = RegExp(r'^test_resources\/trimmed.\.mp4$');

        expect(
            regex.hasMatch((await fileProcessor.getBestMomentByAudio(
                    videoFile, samplingRate))
                .path),
            true);
      });

      test('ut_FileProcessor_getBestMomentByAudio_NoAudioException', () async {
        expect(
            () async =>
                await fileProcessor.getBestMomentByAudio(null, samplingRate),
            throwsA(isInstanceOf<NoAudioException>()));
      });
    });

    group('FileProcessor getBestMomentByScene', () {
      const double samplingRate = 12;

      test('ut_FileProcessor_getBestMomentByScene_default', () async {
        const double meanVolume = 12;
        fileProcessor.meanVolume = meanVolume;
        final List<Duration> sceneMoments = [
          Duration(seconds: 20, milliseconds: 200)
        ];
        fileProcessor.sceneMoments = sceneMoments;
        final List<double> sceneScores = [0.9];
        fileProcessor.sceneScores = sceneScores;

        when(flutterFFprobeMock.getMediaInformation(videoFile.path)).thenAnswer(
            (_) async =>
                Future<Map>.value({'duration': videoDuration.inMilliseconds}));

        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        final regex = RegExp(r'^test_resources\/trimmed.\.mp4$');

        expect(
            regex.hasMatch((await fileProcessor.getBestMomentByScene(
                    videoFile, samplingRate))
                .path),
            true);
      });

      test('ut_FileProcessor_getBestMomentByScene_InvalidVideoFileException',
          () async {
        expect(
            () async =>
                await fileProcessor.getBestMomentByScene(null, samplingRate),
            throwsA(isInstanceOf<InvalidVideoFileException>()));
      });
    });
  });
}
