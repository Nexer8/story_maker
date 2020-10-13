import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storymaker/services/video_processor.dart';

class FlutterFFmpegMock extends Mock implements FlutterFFmpeg {}

class FlutterFFprobeMock extends Mock implements FlutterFFprobe {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('VideoProcessor tests', () {
    final flutterFFmpegMock = FlutterFFmpegMock();
    final flutterFFprobeMock = FlutterFFprobeMock();

    final videoProcessor = VideoProcessor(
        flutterFFmpeg: flutterFFmpegMock,
        flutterFFprobe: flutterFFprobeMock,
        rawDocumentPath: 'test_resources');
    final firstVideo = File('test_resources/sample_video.mp4');
    final secondVideo = File('test_resources/sample_video.mp4');

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
    });
  });
}
