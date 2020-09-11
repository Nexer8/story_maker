import 'dart:io';

import 'package:storymaker/services/audioProcessor.dart';
import 'package:storymaker/services/videoProcessor.dart';

class GeneralStoryProcessor {
  final AudioProcessor _audioProcessor;
  final VideoProcessor _videoProcessor;
  File processedClip;

  GeneralStoryProcessor([this._audioProcessor, this._videoProcessor]);

  int joinAudioAndVideo(File video, File audio) {
    processedClip = null;

    return 0;
  } // TODO: To implement
}
