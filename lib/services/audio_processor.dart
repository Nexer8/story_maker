import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:storymaker/utilities/constants/error_codes.dart';

class AudioProcessor extends FileProcessor {
  File _audio;

  File get audio => _audio;

  set audio(File audio) {
    _audio = audio;
    notifyListeners();
  }

  AudioProcessor(
      {FlutterFFmpeg flutterFFmpeg,
      FlutterFFprobe flutterFFprobe,
      String rawDocumentPath})
      : super(
            flutterFFmpeg: flutterFFmpeg,
            flutterFFprobe: flutterFFprobe,
            rawDocumentPath: rawDocumentPath);

  int getBpmFromAudio(File audio) {
    if (!audio.existsSync()) {
      return invalidFile;
    }

    int bpm;

    return bpm;
  } // TODO: To implement

  Duration getDurationOfOneBar(int bpm) {
    if (bpm <= 0) {
      return null;
    }

    Duration duration;

    return duration;
  } // TODO: To implement
}
