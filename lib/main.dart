import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/screens/main_screen.dart';
import 'package:storymaker/services/audio_processor.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/services/video_processor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          value: VideoProcessor(rawDocumentPath: rawDocumentPath),
        ),
        ChangeNotifierProvider.value(
          value: AudioProcessor(rawDocumentPath: rawDocumentPath),
        ),
        ChangeNotifierProvider.value(
          value: GeneralStoryProcessor(),
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
