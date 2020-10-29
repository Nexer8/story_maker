import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:storymaker/services/audio_processor.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:storymaker/services/video_processor.dart';
import 'package:storymaker/utils/constants/custom_exceptions.dart';
import 'package:storymaker/utils/constants/general_processing_values.dart';

class GeneralStoryProcessor extends ChangeNotifier {
  AudioProcessor _audioProcessor;
  VideoProcessor _videoProcessor;
  File _processedClip;
  ProcessingType processingType = ProcessingType.ByAudio;
  Duration finalDuration = Duration(seconds: 5);

  File get processedClip => _processedClip;

  set processedClip(File processedClip) {
    _processedClip = processedClip;
    notifyListeners();
  }

  GeneralStoryProcessor(this._audioProcessor, this._videoProcessor);

  int getNumberOfLoadedVideos() {
    if (_videoProcessor.videos != null) {
      return _videoProcessor.videos.length;
    } else {
      return 0;
    }
  }

  bool isOperational() => _videoProcessor.videos != null;

  bool isAudioLoaded() => _audioProcessor.audio != null;

  void loadVideos(List<File> videos) {
    _videoProcessor.videos = videos;
  }

  void loadAudio(File audio) {
    _audioProcessor.audio = audio;
  }

  bool isFinalVideoCreated() =>
      _videoProcessor.finalVideo != null &&
      _videoProcessor.finalVideo.existsSync();

  bool isFinalAudioCreated() =>
      _audioProcessor.finalAudio != null &&
      _audioProcessor.finalAudio.existsSync();

  bool areFinalAudioAndVideoCreated() =>
      isFinalAudioCreated() && isFinalVideoCreated();

  bool isVideoToBeWithoutJoiningAudio() =>
      !isFinalAudioCreated() && isFinalVideoCreated();

  void cleanUp() {
    if (processedClip != null && processedClip.existsSync()) {
      processedClip.deleteSync();
    }
    processedClip = null;
  }

  Future<void> makeStory() async {
    if (!isOperational()) {
      throw NoVideosLoadedException();
    }

    cleanUp();

    await _videoProcessor.createFinalVideo(finalDuration, processingType);

    if (_audioProcessor.audio != null) {
      await _audioProcessor.createFinalAudio(finalDuration);
    }

    if (areFinalAudioAndVideoCreated()) {
      processedClip = await joinAudioAndVideo(
          _audioProcessor.finalAudio, _videoProcessor.finalVideo);
    } else if (isVideoToBeWithoutJoiningAudio()) {
      processedClip = _videoProcessor.finalVideo;
    } else {
      throw UnknownException();
    }

    print(processedClip.path);
    print(
        'Processed clip length: ${await _videoProcessor.getDuration(processedClip)}');

    FileProcessor.filesToRemove.remove(processedClip);
    FileProcessor.fileCleanup();
  }

  // Future<void> testFunction() async {
  //   File sample = await _videoProcessor.getBestMomentByAudio(
  //       _videoProcessor.videos.first, 10);
  //
  //   if (sample != null) {
  //     print('Path: ${sample.path}');
  //   }
  //
  //   print('\nPROCESSING VIDEOS!');
  //   processedClip = await _videoProcessor.joinVideos(
  //       _videoProcessor.videos.first, _videoProcessor.videos.last);
  //   print('\nPROCESSED CLIP INFO: $processedClip');
  //
  //   print(
  //       '\nJOINED VIDEOS DURATION: ${await _videoProcessor.getDuration(processedClip)}');
  //
  //   File trimmedVideo = await _videoProcessor.trim(
  //       processedClip, Duration(seconds: 0), Duration(seconds: 1));
  //   print(
  //       '\nDURATION AFTER TRIM: ${await _videoProcessor.getDuration(trimmedVideo)}');
  //
  //   print('\nPROCESSING AUDIO!');
  //   print(
  //       '\nAUDIO DURATION: ${await _audioProcessor.getDuration(_audioProcessor.audio)}');
  //   File trimmedAudio = await _audioProcessor.trim(
  //       _audioProcessor.audio, Duration(seconds: 0), Duration(seconds: 1));
  //   print(
  //       '\nTRIMMED AUDIO DURATION: ${await _audioProcessor.getDuration(trimmedAudio)}');
  //
  //   File joinedFile = await joinAudioAndVideo(trimmedAudio, trimmedVideo);
  //   print('\nJOINED FILE: ${joinedFile.path}');
  //   print(
  //       '\nJOINED FILE DURATION: ${await _videoProcessor.getDuration(joinedFile)}');
  //
  //   processedClip = joinedFile;
  //
  //   FileProcessor.fileCleanup();
  // }

  Future<File> joinAudioAndVideo(File audio, File video) async {
    if (!audio.existsSync() || !video.existsSync()) {
      throw InvalidFileException();
    }

    File extractedAudio = await _videoProcessor.extractAudioFromVideo(video);
    File mergedAudio =
        await _audioProcessor.mergeAudioFiles(audio, extractedAudio);

    File joinedVideo;
    final String outputPath =
        _videoProcessor.rawDocumentPath + "/finalOutput.mp4";

    final String commandToExecute =
        "-y -i '${video.path}' -i '${mergedAudio.path}' -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 $outputPath";

    int rc = await _videoProcessor.flutterFFmpeg.execute(commandToExecute);

    if (rc == 0) {
      joinedVideo = File(outputPath);
      FileProcessor.filesToRemove.add(joinedVideo);

      return joinedVideo;
    } else {
      throw UnknownException();
    }
  }
}
