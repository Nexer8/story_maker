import 'dart:io';

import 'package:storymaker/services/AudioProcessor.dart';
import 'package:storymaker/services/IFileProcessor.dart';
import 'package:storymaker/services/VideoProcessor.dart';

class GeneralStoryProcessor {
  final AudioProcessor _audioProcessor;
  final VideoProcessor _videoProcessor;
  File processedClip;

  GeneralStoryProcessor([this._audioProcessor, this._videoProcessor]);

  Future<void> makeStory() async {
    if (_audioProcessor.audio != null && _videoProcessor.finalVideo != null) {
      processedClip = await joinAudioAndVideo(
          _audioProcessor.audio, _videoProcessor.finalVideo);
    } else if (_audioProcessor.audio == null &&
        _videoProcessor.finalVideo != null) {
      processedClip = _videoProcessor.finalVideo;
    } else {
      print("ERROR");
    }
  }

  Future<void> testFunction() async {
    // processedClip = await _videoProcessor.joinVideos(
    //     _videoProcessor.videos.first, _videoProcessor.videos.last);
    // print('Processed clip info: $processedClip');
    // print(
    //     '\nDuration here: ${await _videoProcessor.getDuration(_videoProcessor.videos.first)}');
    // await _videoProcessor.getFrameRate(_videoProcessor.videos.first);
    int number = 0;
    for (var image in await _videoProcessor
        .getFramesFromVideo(_videoProcessor.videos.first)) {
      print(image);
      number++;
    }
    print("Number of frames: $number!!!");
  }

  Future<File> joinAudioAndVideo(File audio, File video) async {
    final String rawDocumentPath = _videoProcessor.appDocumentDir.path;
    final String outputPath = rawDocumentPath + "/finalOutput.mp4";

    final String commandToExecute =
        "-y -i ${video.path} -i ${audio.path} -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 output.mp4";
    int rc = await IFileProcessor.flutterFFmpeg.execute(commandToExecute);

    return rc == 0 ? File(outputPath) : null;
  } // TODO: To test
}
