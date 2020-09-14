import 'package:flutter_test/flutter_test.dart';
import 'package:storymaker/services/VideoProcessor.dart';

void main() {
  group('VideoProcessor tests', () {
    final VideoProcessor videoProcessor = VideoProcessor();

    group('VideoProcessor joinVideos', () {
      test('it_VideoProcessor_joinVideos_default', () async {
        expect(1, 1);
      });
    });

    group('VideoProcessor getFrameRate', () {
      test('it_VideoProcessor_getFrameRate_default', () async {
        expect(1, 1);
      });
    });

    group('VideoProcessor getFramesFromVideo', () {
      test('it_VideoProcessor_getFramesFromVideo_default', () async {
        expect(1, 1);
      });
    });
  });
}
