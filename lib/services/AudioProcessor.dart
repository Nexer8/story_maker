import 'dart:io';

import 'package:storymaker/services/IFileProcessor.dart';

class AudioProcessor implements IFileProcessor {
  Future<File> audio;

  File trimFromStart(File audio, Duration duration) {
    File trimmedAudio;

    return trimmedAudio;
  } // TODO: To implement

  File trimFromEnd(File audio, Duration duration) {
    File trimmedAudio;

    return trimmedAudio;
  } // TODO: To implement

  Duration getDuration(File audio) {
    Duration duration;

    return duration;
  } // TODO: To implement

  int getBpmFromAudio(File audio) {
    int bpm;

    return bpm;
  } // TODO: To implement

  Duration getDurationOfOneBar(int bpm) {
    Duration duration;

    return duration;
  } // TODO: To implement
}
