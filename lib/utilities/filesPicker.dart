import 'dart:io';
import 'package:multi_media_picker/multi_media_picker.dart';
import 'package:audio_picker/audio_picker.dart';

class FilesPicker {
  static Future<List<File>> pickVideosFromGallery() async =>
      await MultiMediaPicker.pickImages(source: ImageSource.gallery);

  static Future<File> pickAudioFromDevice() async =>
      File(await AudioPicker.pickAudio());
}
