import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/components/error_handling_snackbar.dart';
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
            ProgressDialog progressDialog =
                ProgressDialogWindow.getProgressDialog(
                    context, 'Making a story');
            await progressDialog.show();

            try {
              await generalStoryProcessor.makeStory();
            } catch (e) {
              ErrorHandlingSnackbar.show(e, context);
            } finally {
              await progressDialog.hide();
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
