import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storymaker/services/audio_processor.dart';
import 'package:mockito/mockito.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/services/video_processor.dart';
import 'package:storymaker/utils/constants/general_processing_values.dart';

class AudioProcessorMock extends Mock implements AudioProcessor {}

class VideoProcessorMock extends Mock implements VideoProcessor {}

class FlutterFFmpegMock extends Mock implements FlutterFFmpeg {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('GeneralProcessor tests', () {
    final audioProcessorMock = AudioProcessorMock();
    final videoProcessorMock = VideoProcessorMock();
    final flutterFFmpegMock = FlutterFFmpegMock();

    final generalStoryProcessor =
        GeneralStoryProcessor(audioProcessorMock, videoProcessorMock);

    final audioFile = File('test_resources/sample_audio.mp3');
    final videoFile = File('test_resources/sample_video.mp4');
    final String rawDocumentPath = 'test_resources';
    final finalDuration = Duration(seconds: 5);
    final processingType = ProcessingType.ByAudio;

    tearDown(() {
      videoProcessorMock.videos = null;
      videoProcessorMock.finalVideo = null;
      audioProcessorMock.audio = null;
      audioProcessorMock.finalAudio = null;
      generalStoryProcessor.processedClip = null;
    });

    group('GeneralStoryProcessor joinAudioAndVideo', () {
      test('ut_GeneralStoryProcessor_joinAudioAndVideo_default', () async {
        final extractedAudio = File('');
        final mergedAudio = File('');

        when(videoProcessorMock.extractAudioFromVideo(videoFile))
            .thenAnswer((_) async => Future<File>.value(extractedAudio));

        when(audioProcessorMock.mergeAudioFiles(audioFile, extractedAudio))
            .thenAnswer((_) async => Future<File>.value(mergedAudio));

        when(videoProcessorMock.rawDocumentPath).thenReturn(rawDocumentPath);

        when(videoProcessorMock.flutterFFmpeg).thenReturn(flutterFFmpegMock);

        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        final regex = RegExp(r'^test_resources\/finalOutput\.mp4$');

        expect(
            regex.hasMatch((await generalStoryProcessor.joinAudioAndVideo(
                    audioFile, videoFile))
                .path),
            true);
      });
    });

    group('GeneralStoryProcessor makeStory', () {
      test('ut_GeneralStoryProcessor_makeStory_video_only_default', () async {
        when(videoProcessorMock.videos).thenReturn([videoFile]);
        when(videoProcessorMock.finalVideo).thenReturn(videoFile);
        when(audioProcessorMock.audio).thenReturn(null);
        when(audioProcessorMock.finalAudio).thenReturn(null);

        await generalStoryProcessor.makeStory();

        verify(videoProcessorMock.createFinalVideo(
                finalDuration, processingType))
            .called(1);
        verifyNever(audioProcessorMock.createFinalAudio(finalDuration));
      });

      test('ut_GeneralStoryProcessor_makeStory_video_and_audio_default',
          () async {
        final extractedAudio = File('');
        final mergedAudio = File('');

        when(videoProcessorMock.videos).thenReturn([videoFile]);
        when(videoProcessorMock.finalVideo).thenReturn(videoFile);
        when(audioProcessorMock.audio).thenReturn(audioFile);
        when(audioProcessorMock.finalAudio).thenReturn(audioFile);

        when(videoProcessorMock.extractAudioFromVideo(videoFile))
            .thenAnswer((_) async => Future<File>.value(extractedAudio));

        when(audioProcessorMock.mergeAudioFiles(audioFile, extractedAudio))
            .thenAnswer((_) async => Future<File>.value(mergedAudio));

        when(videoProcessorMock.rawDocumentPath).thenReturn(rawDocumentPath);

        when(videoProcessorMock.flutterFFmpeg).thenReturn(flutterFFmpegMock);

        when(flutterFFmpegMock.execute(any))
            .thenAnswer((_) async => Future<int>.value(0));

        await generalStoryProcessor.makeStory();

        verify(videoProcessorMock.createFinalVideo(
                finalDuration, processingType))
            .called(1);
        verify(audioProcessorMock.createFinalAudio(finalDuration)).called(1);
      });
    });
  });
}
