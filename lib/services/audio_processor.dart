import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:storymaker/utilities/constants/general_processing_values.dart';

class AudioProcessor extends FileProcessor {
  File _audio;
  File _finalAudio;

  File get audio => _audio;

  set audio(File audio) {
    _audio = audio;
    notifyListeners();
  }

  File get finalAudio => _finalAudio;

  set finalAudio(File finalAudio) {
    _finalAudio = finalAudio;
    notifyListeners();
  }

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
      print('Final Duration > Maximal Duration');
      return;
    }

    Duration duration = await getDuration(audio);
    File bestAudio = await getBestMomentByAudio(
        audio, duration.inMicroseconds / finalDuration.inMilliseconds);

    finalAudio = bestAudio;
  }
}
