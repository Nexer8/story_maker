import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/components/error_handling_snackbar.dart';
import 'package:storymaker/components/progress_dialog_window.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/utils/constants/colors.dart';

class MakeStoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return Container(
      padding: const EdgeInsets.only(
          left: 25.0, top: 5.0, right: 25.0, bottom: 15.0),
      height: 80.0,
      child: MaterialButton(
        color: kSecondaryColor,
        onPressed: () async {
          ProgressDialog progressDialog =
              ProgressDialogWindow.getProgressDialog(context, 'Making a story');
          await progressDialog.show();

          try {
            await generalStoryProcessor.makeStory();
          } catch (e) {
            ErrorHandlingSnackbar.show(e, context);
          } finally {
            await progressDialog.hide();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_creation,
              color: kOnSecondaryColor,
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              'Make your own story',
              style: TextStyle(
                  color: kOnSecondaryColor,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
