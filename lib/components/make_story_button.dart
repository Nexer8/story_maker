import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/components/progress_dialog_window.dart';
import 'package:storymaker/services/general_processor.dart';

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

              ProgressDialog progressDialog =
                  ProgressDialogWindow.getProgressDialog(
                      context, 'Making a story');
              progressDialog.show();

              try {
                await generalStoryProcessor.makeStory();
              } catch (e) {
                progressDialog.hide();
              }

              if (progressDialog.isShowing()) {
                progressDialog.hide();
              }
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
