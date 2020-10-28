import 'dart:io';

class ClipSample {
  final File file;
  final Duration startingPoint;
  final Duration endingPoint;
  double meanVolume;
  double bestSceneScore;

  ClipSample(
      {this.file,
      this.startingPoint,
      this.endingPoint,
      this.meanVolume,
      this.bestSceneScore});
}
