import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:storymaker/services/ClipSample.dart';
import 'package:storymaker/services/audio_processor.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:storymaker/services/video_processor.dart';

class GeneralStoryProcessor extends ChangeNotifier {
  AudioProcessor _audioProcessor;
  VideoProcessor _videoProcessor;
  File _processedClip;

  AudioProcessor get audioProcessor => _audioProcessor;

  set audioProcessor(AudioProcessor audioProcessor) {
    _audioProcessor = audioProcessor;
    notifyListeners();
  }

  VideoProcessor get videoProcessor => _videoProcessor;

  set videoProcessor(VideoProcessor videoProcessor) {
    _videoProcessor = videoProcessor;
    notifyListeners();
  }

  File get processedClip => _processedClip;

  set processedClip(File processedClip) {
    _processedClip = processedClip;
    notifyListeners();
  }

  GeneralStoryProcessor(this._audioProcessor, this._videoProcessor);

  void loadVideos(List<File> videos) {
    _videoProcessor.videos = videos;
  }

  void loadAudio(File audio) {
    _audioProcessor.audio = audio;
  }

  bool isOperational() {
    if (_videoProcessor.videos != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> makeStory() async {
    if (_audioProcessor.audio.existsSync() &&
        _videoProcessor.finalVideo.existsSync()) {
      processedClip = await joinAudioAndVideo(
          _audioProcessor.audio, _videoProcessor.finalVideo);
    } else if (_audioProcessor.audio == null &&
        _videoProcessor.finalVideo.existsSync()) {
      processedClip = _videoProcessor.finalVideo;
    } else {
      print("ERROR");
    }
  }

  Future<void> testFunction() async {
    List<ClipSample> samples = await _videoProcessor.getBestMomentsByAudio(
        videoProcessor.videos.first, 10);

    if (samples.isNotEmpty) {
      for (var sample in samples) {
        print('Path: ${sample.file.path}');
        print('Starting point: ${sample.startingPoint}');
        print('Ending point: ${sample.endingPoint}');
        print('Mean volume: ${sample.meanVolume}');
      }
    }

    print('\nPROCESSING VIDEOS!');
    processedClip = await _videoProcessor.joinVideos(
        _videoProcessor.videos.first, _videoProcessor.videos.last);
    print('\nPROCESSED CLIP INFO: $processedClip');

    print(
        '\nJOINED VIDEOS DURATION: ${await _videoProcessor.getDuration(processedClip)}');

    print('\nFRAME RATE: ${await _videoProcessor.getFrameRate(processedClip)}');
    int number = 0;
    for (var image in await _videoProcessor.getFramesFromVideo(processedClip)) {
      print(image);
      number++;
    }
    print("\nNUMBER OF FRAMES: $number!!!");

    File trimmedVideo = await _videoProcessor.trim(
        processedClip, Duration(seconds: 0), Duration(seconds: 1));
    print(
        '\nDURATION AFTER TRIM: ${await _videoProcessor.getDuration(trimmedVideo)}');

    print('\nPROCESSING AUDIO!');
    print(
        '\nAUDIO DURATION: ${await _audioProcessor.getDuration(_audioProcessor.audio)}');
    File trimmedAudio = await _audioProcessor.trim(
        _audioProcessor.audio, Duration(seconds: 0), Duration(seconds: 1));
    print(
        '\nTRIMMED AUDIO DURATION: ${await _audioProcessor.getDuration(trimmedAudio)}');

    File joinedFile = await joinAudioAndVideo(trimmedAudio, trimmedVideo);
    print('\nJOINED FILE: ${joinedFile.path}');
    print(
        '\nJOINED FILE DURATION: ${await _videoProcessor.getDuration(joinedFile)}');

    processedClip = joinedFile;

    FileProcessor.fileCleanup();
  }

  Future<File> joinAudioAndVideo(File audio, File video) async {
    if (!audio.existsSync() || !video.existsSync()) {
      return null;
    }

    File joinedVideo;
    final String outputPath =
        _videoProcessor.rawDocumentPath + "/finalOutput.mp4";

    final String commandToExecute =
        "-y -i ${video.path} -i ${audio.path} -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 $outputPath";

    int rc = await videoProcessor.flutterFFmpeg.execute(commandToExecute);

    if (rc == 0) {
      joinedVideo = File(outputPath);
      // FileProcessor.createdFiles.add(joinedVideo);

      return joinedVideo;
    } else {
      return null;
    }
  }
}
