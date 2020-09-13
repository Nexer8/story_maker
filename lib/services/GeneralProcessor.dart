import 'dart:io';

import 'package:storymaker/services/AudioProcessor.dart';
import 'package:storymaker/services/VideoProcessor.dart';

class GeneralStoryProcessor {
  final AudioProcessor _audioProcessor;
  final VideoProcessor _videoProcessor;
  File processedClip; // TODO: To decide whether optional

  GeneralStoryProcessor([this._audioProcessor, this._videoProcessor]);

  int joinAudioAndVideo(File video, File audio) {
    processedClip = null;

    return 0;
  } // TODO: To implement
}
