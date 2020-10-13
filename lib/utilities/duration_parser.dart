class DurationParser {
  static Duration parseDuration(String s) {
    int seconds = 0;
    int microseconds = 0;
    List<String> parts = s.split('.');

    if (parts.length == 2) {
      seconds = int.parse(parts.first);

      if (parts.last.length == 1) {
        microseconds = int.parse(parts.last) * 100000;
      } else if (parts.last.length == 2) {
        microseconds = int.parse(parts.last) * 10000;
      } else if (parts.last.length == 3) {
        microseconds = int.parse(parts.last) * 1000;
      } else if (parts.last.length == 4) {
        microseconds = int.parse(parts.last) * 100;
      }
    } else if (parts.length == 1) {
      seconds = int.parse(parts.first);
    }

    return Duration(seconds: seconds, microseconds: microseconds);
  }
}
