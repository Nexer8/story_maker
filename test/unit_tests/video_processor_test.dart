import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storymaker/services/video_processor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('VideoProcessor tests', () {
    final VideoProcessor videoProcessor =
        VideoProcessor(rawDocumentPath: 'test_resources');
    final File firstVideo = File('test_resources/sample_video.mp4');
    final File secondVideo = File('test_resources/sample_video.mp4');
    const int firstVideoFrameRate = 30;

    group('VideoProcessor joinVideos', () {
      test('ut_VideoProcessor_joinVideos_default', () async {
        File joinedVideo =
            await videoProcessor.joinVideos(firstVideo, secondVideo);

        expect(joinedVideo.existsSync(), true);

        expect(
            await videoProcessor.getDuration(joinedVideo),
            await videoProcessor.getDuration(firstVideo) +
                await videoProcessor.getDuration(secondVideo));
      });
    });

    group('VideoProcessor getFrameRate', () {
      test('ut_VideoProcessor_getFrameRate_default', () async {
        expect(
            await videoProcessor.getFrameRate(firstVideo), firstVideoFrameRate);
      });
    });

    group('VideoProcessor getFramesFromVideo', () {
      test('ut_VideoProcessor_getFramesFromVideo_default', () async {
        List<File> videoFrames =
            await videoProcessor.getFramesFromVideo(firstVideo);

        for (var frame in videoFrames) {
          expect(frame.existsSync(), true);
        }

        expect(
            videoFrames.length,
            await videoProcessor.getDuration(firstVideo) *
                await videoProcessor.getFrameRate(firstVideo));
      });
    });
  });
}
