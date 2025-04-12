double parseVersion(String version) {
  try {
    return double.parse(version);
  } catch (e) {
    List<String> parts = version.split('.');
    String temp = parts[0] + '.';

    parts.removeAt(0);
    return double.parse(temp + parts.join(''));
  }
}
