import 'dart:io';

import 'package:storymaker/services/IFileProcessor.dart';

class AudioProcessor extends IFileProcessor {
  static int outputId = 0;
  File audio;
  Directory appDocumentDir;

  AudioProcessor({this.audio, this.appDocumentDir});

  int getBpmFromAudio(File audio) {
    int bpm;

    return bpm;
  } // TODO: To implement

  Duration getDurationOfOneBar(int bpm) {
    Duration duration;

    return duration;
  } // TODO: To implement
}
