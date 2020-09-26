import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:storymaker/screens/main_screen.dart';
import 'package:storymaker/services/audio_processor.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/services/service_locator.dart';
import 'package:storymaker/services/video_processor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DIContainer.registerServices();

  final Directory appDocumentDir = await getApplicationDocumentsDirectory();

  runApp(StoryMaker(appDocumentDir.path));
}

class StoryMaker extends StatelessWidget {
  final String rawDocumentPath;

  StoryMaker(this.rawDocumentPath);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: GeneralStoryProcessor(
              AudioProcessor(
                  flutterFFmpeg: DIContainer.getIt.get<FlutterFFmpeg>(),
                  flutterFFprobe: DIContainer.getIt.get<FlutterFFprobe>(),
                  rawDocumentPath: rawDocumentPath),
              VideoProcessor(
                  flutterFFmpeg: DIContainer.getIt.get<FlutterFFmpeg>(),
                  flutterFFprobe: DIContainer.getIt.get<FlutterFFprobe>(),
                  rawDocumentPath: rawDocumentPath)),
        ),
      ],
      child: MaterialApp(
        initialRoute: MainScreen.id,
        routes: {
          MainScreen.id: (context) => MainScreen(),
        },
      ),
    );
  }
}
