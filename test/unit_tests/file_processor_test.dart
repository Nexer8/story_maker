// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:storymaker/services/file_processor.dart';
// import 'package:mockito/mockito.dart';
//
// // class FlutterFFmpegMock extends Mock implements FlutterFFmpeg {}
// //
// // class FlutterFFprobeMock extends Mock implements FlutterFFprobe {}
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   group('FileProcessor tests', () {
//     // final FlutterFFmpegMock flutterFFmpegMock = FlutterFFmpegMock();
//     // final FlutterFFprobeMock flutterFFprobeMock = FlutterFFprobeMock();
//
//     final FileProcessor fileProcessor = FileProcessor(
//         // flutterFFmpeg: flutterFFmpegMock,
//         // flutterFFprobe: flutterFFprobeMock,
//         rawDocumentPath: 'test_resources');
//     final File audioFile = File('test_resources/sample_audio.mp3');
//     final File videoFile = File('test_resources/sample_video.mp4');
//     final Duration audioDuration = Duration(seconds: 27);
//
//     group('FileProcessor trim', () {
//       Duration startingPoint = Duration(seconds: 0);
//       Duration endingPoint = startingPoint + Duration(seconds: 1);
//
//       test('ut_FileProcessor_trim_audio_default', () async {
//         when(FileProcessor.flutterFFmpeg.execute(any))
//             .thenAnswer((_) async => Future<int>.value(0));
//
//         final regex = RegExp(r'^test_resources\/output.\.mp3$');
//
//         expect(
//             regex.hasMatch((await fileProcessor.trim(
//                     audioFile, startingPoint, endingPoint))
//                 .path),
//             true);
//       });
//
//       test('ut_FileProcessor_trim_video_default', () async {
//         when(FileProcessor.flutterFFmpeg.execute(any))
//             .thenAnswer((_) async => Future<int>.value(0));
//
//         final regex = RegExp(r'^test_resources\/output.\.mp4$');
//
//         expect(
//             regex.hasMatch((await fileProcessor.trim(
//                     videoFile, startingPoint, endingPoint))
//                 .path),
//             true);
//       });
//     });
//
//     group('FileProcessor getDuration', () {
//       test('ut_FileProcessor_getDuration_default', () async {
//         when(FileProcessor.flutterFFprobe.getMediaInformation(audioFile.path))
//             .thenAnswer((_) async =>
//                 Future<Map>.value({'duration': audioDuration.inMilliseconds}));
//
//         expect(await fileProcessor.getDuration(audioFile), audioDuration);
//       });
//     });
//   });
// }
