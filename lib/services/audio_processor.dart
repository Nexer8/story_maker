import 'dart:io';

import 'package:storymaker/services/file_processor.dart';
import 'package:storymaker/utilities/constants/error_codes.dart';

class AudioProcessor extends FileProcessor {
  static int outputId = 0;
  File audio;
  Directory appDocumentDir;

  AudioProcessor({this.audio, this.appDocumentDir});

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