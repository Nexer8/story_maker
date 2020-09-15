import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storymaker/services/audio_processor.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/services/video_processor.dart';
import 'package:storymaker/utilities/constants/screen_ids.dart';
import 'package:storymaker/utilities/files_picker.dart';

class MainScreen extends StatefulWidget {
  static const String id = mainScreenId;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GeneralStoryProcessor generalStoryProcessor;
  AudioProcessor audioProcessor;
  VideoProcessor videoProcessor;

  // void _incrementCounter() {
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {}, // TODO: Implement player
              child: Ink(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    height: 200.0,
                    width: double.infinity,
                    color: Colors.black,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          print('Video button was pressed');
                          List<File> videos =
                              await FilesPicker.pickVideosFromGallery();

                          if (videos != null) {
                            final Directory appDocumentDir =
                                await getApplicationDocumentsDirectory();

                            print('\nVideos: ');
                            print(videos);
                            videoProcessor = VideoProcessor(
                                videos: videos,
                                rawDocumentPath: appDocumentDir.path);
                          }
                        },
                        child: Ink(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            height: double.infinity,
                            width: double.infinity,
                            child: Icon(Icons.video_library),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          print('Audio button was pressed');
                          File audio = await FilesPicker.pickAudioFromDevice();

                          if (audio != null) {
                            final Directory appDocumentDir =
                                await getApplicationDocumentsDirectory();
                            audioProcessor = AudioProcessor(
                                audio: audio,
                                rawDocumentPath: appDocumentDir.path);
                          }
                        },
                        child: Ink(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            height: double.infinity,
                            width: double.infinity,
                            child: Icon(Icons.audiotrack),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: MaterialButton(
                  onPressed: () async {
                    print("Create story button has been pressed");

                    if (videoProcessor != null) {
                      generalStoryProcessor = GeneralStoryProcessor(
                          this.audioProcessor = audioProcessor,
                          this.videoProcessor = videoProcessor);
                      print('General story processor has been created!');

                      await generalStoryProcessor.testFunction();
                    } else {
                      print('No processor created');
                    }
                  },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie_creation),
                        Text('Make your own story'),
                      ],
                    ),
                  ),
                  color: Colors.blueGrey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
