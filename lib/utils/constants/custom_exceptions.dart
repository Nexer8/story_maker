class NoVideosLoadedException implements Exception {
  @override
  String toString() => 'No videos loaded!';
}

class ExceededDurationException implements Exception {
  @override
  String toString() => 'Final duration is over 15s!';
}

class NoAudioException implements Exception {
  @override
  String toString() => 'Video has no audio track!';
}

class VideosShortenThanFinalDurationException implements Exception {
  @override
  String toString() =>
      'Loaded videos combined are shorter than final duration!';
}

class VideosShorterThanMinimalDurationException implements Exception {
  @override
  String toString() => 'Loaded videos combined are shorter than 1s!';
}

class InvalidVideoFileException implements Exception {
  @override
  String toString() => 'At least one of the video files is invalid!';
}

class InvalidFileException implements Exception {
  @override
  String toString() => 'At least one of the files is invalid!';
}

class UnknownException implements Exception {
  @override
  String toString() => 'Unknown exception occurred! Please try again.';
}
