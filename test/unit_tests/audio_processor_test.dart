import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storymaker/services/audio_processor.dart';

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

        await audioProcessor.createFinalAudio(finalDuration);
        expect(audioProcessor.finalAudio.path, finalAudio.path);
      });
    });
  });
}
