import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FilesPicker {
  static Future<List<File>> pickVideosFromGallery() async {
    List<File> files = List<File>();

    FilePickerResult filePickerResult = await FilePicker.platform
        .pickFiles(type: FileType.video, allowMultiple: true);

    for (var file in filePickerResult.files) {
      files.add(File(file.path));
    }

    return files;
  }

  static Future<File> pickAudioFromDevice() async {
    FilePickerResult filePickerResult =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (filePickerResult != null) {
      return File(filePickerResult.files.first.path);
    } else {
      return null;
    }
  }
}
