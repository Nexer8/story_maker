import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/utils/constants/colors.dart';
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
            child: Text(
              'Attractiveness indicator',
              style: TextStyle(
                  fontSize: 20.0,
                  color: kOnPrimaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Radio(
                value: ProcessingType.ByAudio,
                groupValue: _value,
                activeColor: kSecondaryLightColor,
                onChanged: (Object value) {
                  setState(() {
                    _value = value;
                    generalStoryProcessor.processingType = value;
                  });
                },
              ),
              Text(
                'Audio',
                style: TextStyle(
                  fontSize: 20.0,
                  color: kOnPrimaryColor,
                ),
              ),
              SizedBox(
                width: 60,
              ),
              Radio(
                value: ProcessingType.ByScene,
                groupValue: _value,
                activeColor: kSecondaryLightColor,
                onChanged: (Object value) {
                  setState(() {
                    _value = value;
                    generalStoryProcessor.processingType = value;
                  });
                },
              ),
              Text(
                'Movement',
                style: TextStyle(
                  fontSize: 20.0,
                  color: kOnPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
