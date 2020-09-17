import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/services/audio_processor.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/services/video_processor.dart';

class MakeStoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioProcessor = Provider.of<AudioProcessor>(context);
    final videoProcessor = Provider.of<VideoProcessor>(context);
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: MaterialButton(
          onPressed: () async {
            print("Create story button has been pressed");

            if (videoProcessor != null) {
              generalStoryProcessor.videoProcessor = videoProcessor;

              if (audioProcessor != null) {
                generalStoryProcessor.audioProcessor = audioProcessor;
              }
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
    );
  }
}
