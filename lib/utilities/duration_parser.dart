class DurationParser {
  static Duration parseDuration(String s) {
    int seconds = 0;
    int milliseconds = 0;
    List<String> parts = s.split('.');

    seconds = int.parse(parts.first);
    milliseconds = int.parse(parts.last);

    return Duration(seconds: seconds, milliseconds: milliseconds);
  }
}
