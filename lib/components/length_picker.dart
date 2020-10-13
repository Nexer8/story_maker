import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/utilities/constants/general_processing_values.dart';

class LengthPicker extends StatefulWidget {
  @override
  _LengthPickerState createState() => _LengthPickerState();
}

class _LengthPickerState extends State<LengthPicker> {
  double duration = 5;

  @override
  Widget build(BuildContext context) {
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Choose clip duration',
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        Slider(
          min: minimalDuration.inSeconds.toDouble(),
          max: maximalDuration.inSeconds.toDouble(),
          value: duration,
          divisions: 15,
          label: duration.round().toString(),
          activeColor: Colors.orange,
          onChanged: (val) {
            setState(() {
              duration = val;
              generalStoryProcessor.finalDuration =
                  Duration(seconds: duration.round());
            });
          },
        ),
      ],
    );
  }
}
