import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:storymaker/utils/constants/custom_exceptions.dart';
import 'package:storymaker/utils/constants/general_processing_values.dart';

class AudioProcessor extends FileProcessor {
  File audio;
  File finalAudio;

  AudioProcessor(
      {FlutterFFmpeg flutterFFmpeg,
      FlutterFFprobe flutterFFprobe,
      FlutterFFmpegConfig flutterFFmpegConfig,
      String rawDocumentPath})
      : super(
            flutterFFmpeg: flutterFFmpeg,
            flutterFFprobe: flutterFFprobe,
            flutterFFmpegConfig: flutterFFmpegConfig,
            rawDocumentPath: rawDocumentPath);

  Future<void> createFinalAudio(Duration finalDuration) async {
    if (finalDuration > maximalDuration) {
      throw ExceededDurationException();
    }

    Duration duration = await getDuration(audio);
    File bestAudio = await getBestMomentByAudio(
        audio, duration.inMicroseconds / finalDuration.inMicroseconds);

    finalAudio = bestAudio;
  }
}
