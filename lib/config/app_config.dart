class AppConfig {
  static const String appName = 'Medigo Admin';
  static const String version = '1.0.0';
  static bool get isDebug {
    bool result = false;
    assert(() {
      result = true;
      return true;
    }());
    return result;
  }
}
