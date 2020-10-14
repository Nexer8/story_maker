import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/utils/constants/general_processing_values.dart';

class ProcessingOptionPicker extends StatefulWidget {
  @override
  _ProcessingOptionPickerState createState() => _ProcessingOptionPickerState();
}

class _ProcessingOptionPickerState extends State<ProcessingOptionPicker> {
  ProcessingType _value;

  @override
  void initState() {
    setState(() {
      _value = ProcessingType.ByAudio;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('What is more important in your clips?',
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              value: ProcessingType.ByAudio,
              groupValue: _value,
              activeColor: Colors.orangeAccent,
              onChanged: (Object value) {
                setState(() {
                  _value = value;
                  generalStoryProcessor.processingType = value;
                  print(generalStoryProcessor.processingType);
                });
              },
            ),
            Text(
              'Audio',
              style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 60,
            ),
            Radio(
              value: ProcessingType.ByScene,
              groupValue: _value,
              activeColor: Colors.orangeAccent,
              onChanged: (Object value) {
                setState(() {
                  _value = value;
                  generalStoryProcessor.processingType = value;
                  print(generalStoryProcessor.processingType);
                });
              },
            ),
            Text(
              'Movement',
              style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
