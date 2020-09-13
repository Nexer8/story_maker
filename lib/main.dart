import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storymaker/screens/MainScreen.dart';

void main() {
  runApp(StoryMaker());
}

class StoryMaker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: MainScreen.id,
      routes: {
        MainScreen.id: (context) => MainScreen(),
      },
    );
  }
}
