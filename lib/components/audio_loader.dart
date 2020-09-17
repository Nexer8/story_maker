import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/services/audio_processor.dart';
import 'package:storymaker/utilities/files_picker.dart';

class AudioLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioProcessor = Provider.of<AudioProcessor>(context);

    return Expanded(
      child: InkWell(
        onTap: () async {
          print('Audio button was pressed');
          File audio = await FilesPicker.pickAudioFromDevice();

          if (audio != null) {
            audioProcessor.audio = audio;
          }
          // setState(() {});
        },
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
    );
  }
}
