import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:storymaker/services/file_processor.dart';
import 'package:storymaker/utils/constants/custom_exceptions.dart';
import 'package:storymaker/utils/constants/general_processing_values.dart';

class AudioProcessor extends FileProcessor {
  File audio;
  File finalAudio;

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

  Future<File> mergeAudioFiles(File firstAudio, File secondAudio) async {
    if (!firstAudio.existsSync() || !secondAudio.existsSync()) {
      throw InvalidFileException();
    }

    File mergedAudio;
    final String outputPath =
        rawDocumentPath + "/mergedAudio${FileProcessor.outputId}.mp3";

    final String commandToExecute =
        "-y -i ${firstAudio.path} -i ${secondAudio.path}"
        " -filter_complex amerge -c:a libmp3lame -q:a 4 $outputPath";

    int rc = await flutterFFmpeg.execute(commandToExecute);

    if (rc == 0) {
      mergedAudio = File(outputPath);
      FileProcessor.filesToRemove.add(mergedAudio);

      return mergedAudio;
    } else {
      throw UnknownException();
    }
  }

  Future<void> createFinalAudio(Duration finalDuration) async {
    if (finalDuration > maximalDuration) {
      throw ExceededDurationException();
    }

    Duration duration = await getDuration(audio);
    File bestAudio = await getBestMomentByAudio(
        audio, duration.inMicroseconds / finalDuration.inMicroseconds);

    finalAudio = bestAudio;
  }
}
