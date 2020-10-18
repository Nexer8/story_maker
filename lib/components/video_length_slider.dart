import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storymaker/services/general_processor.dart';
import 'package:storymaker/utils/constants/colors.dart';
import 'package:storymaker/utils/constants/general_processing_values.dart';
import 'package:storymaker/utils/custom_slider_component_shape.dart';

class VideoLengthSlider extends StatefulWidget {
  @override
  _VideoLengthSliderState createState() => _VideoLengthSliderState();
}

class _VideoLengthSliderState extends State<VideoLengthSlider> {
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
            child: Text(
              'Clip duration',
              style: TextStyle(
                  fontSize: 20.0,
                  color: kOnPrimaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 10.0, top: 8.0, right: 10.0, bottom: 3.0),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              showValueIndicator: ShowValueIndicator.never,
              trackHeight: 4.0,
              thumbShape: CustomSliderComponentShape(
                thumbRadius: 22,
                min: 1,
                max: 15,
              ),
              // activeTrackColor: Colors.white.withOpacity(1),
              // inactiveTrackColor: Colors.white.withOpacity(.5),
              // overlayColor: Colors.white.withOpacity(.4),
              // valueIndicatorColor: Colors.white,
              // activeTickMarkColor: Colors.white,
              // inactiveTickMarkColor: Colors.red.withOpacity(.7),
            ),
            child: Slider(
              min: minimalDuration.inSeconds.toDouble(),
              max: maximalDuration.inSeconds.toDouble(),
              value: duration,
              divisions: 14,
              label: duration.round().toString(),
              activeColor: kSecondaryColor,
              inactiveColor: kSecondaryDarkColor,
              onChanged: (val) {
                setState(() {
                  duration = val;
                  generalStoryProcessor.finalDuration =
                      Duration(seconds: duration.round());
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
