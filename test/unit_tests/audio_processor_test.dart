import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storymaker/services/audio_processor.dart';
import 'package:storymaker/utils/constants/custom_exceptions.dart';

class FlutterFFmpegMock extends Mock implements FlutterFFmpeg {}

class FlutterFFprobeMock extends Mock implements FlutterFFprobe {}

class FlutterFFmpegConfigMock extends Mock implements FlutterFFmpegConfig {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('AudioProcessor tests', () {
    final flutterFFmpegMock = FlutterFFmpegMock();
    final flutterFFprobeMock = FlutterFFprobeMock();
    final flutterFFmpegConfigMock = FlutterFFmpegConfigMock();

    final audioProcessor = AudioProcessor(
        flutterFFmpeg: flutterFFmpegMock,
        flutterFFprobe: flutterFFprobeMock,
        flutterFFmpegConfig: flutterFFmpegConfigMock,
        rawDocumentPath: 'test_resources');
    final audioFile = File('test_resources/sample_audio.mp3');

    group('AudioProcessor createFinalAudio', () {
      test('ut_AudioProcessor_createFinalAudio_default', () async {
        final finalDuration = Duration(seconds: 1);
        final duration = Duration(seconds: 5);
        final finalAudio = File('test_resources/trimmed0.mp3');
        audioProcessor.audio = audioFile;
        audioProcessor.maxVolume = 20;
        audioProcessor.meanVolume = 10;

        when(flutterFFprobeMock.getMediaInformation(audioFile.path)).thenAnswer(
            (_) async =>
                Future<Map>.value({'duration': duration.inMilliseconds}));

        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        final createdFinalAudio =
            await audioProcessor.createFinalAudio(finalDuration);
        expect(createdFinalAudio.path, finalAudio.path);
      });

      test('ut_AudioProcessor_createFinalAudio_ExceededDurationException', () {
        final exceededDuration = Duration(seconds: 16);

        expect(
            () async => await audioProcessor.createFinalAudio(exceededDuration),
            throwsA(isInstanceOf<ExceededDurationException>()));
      });
    });

    group('AudioProcessor mergeAudioFiles', () {
      test('ut_AudioProcessor_mergeAudioFiles_default', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        final regex = RegExp(r'^test_resources\/mergedAudio.\.mp3$');

        expect(
            regex.hasMatch(
                (await audioProcessor.mergeAudioFiles(audioFile, audioFile))
                    .path),
            true);
      });

      test('ut_AudioProcessor_mergeAudioFiles_InvalidFileException', () async {
        expect(
            () async =>
                await audioProcessor.mergeAudioFiles(File(''), File('')),
            throwsA(isInstanceOf<InvalidFileException>()));
      });

      test('ut_AudioProcessor_mergeAudioFiles_UnknownException', () async {
        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(-1));

        expect(
            () async =>
                await audioProcessor.mergeAudioFiles(audioFile, audioFile),
            throwsA(isInstanceOf<UnknownException>()));
      });
    });
  });
}
