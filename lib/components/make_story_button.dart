import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/utilities/constants/general_processing_values.dart';

class MakeStoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: MaterialButton(
          onPressed: () async {
            print("Create story button has been pressed");

            if (generalStoryProcessor.isOperational()) {
              print('General story processor is operational!');

              await generalStoryProcessor.makeStory(
                  ProcessingType.ByScene); //TODO: remove hardcoded values
            } else {
              print('Not operational');
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
