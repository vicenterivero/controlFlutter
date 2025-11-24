class AppConfig {
  static String baseAddress = "http://172.30.3.163:5000";

  static void updateBase(String raw) {
    String candidate = raw.trim();
    if (candidate.startsWith('http://') || candidate.startsWith('https://')) {
      baseAddress = candidate;
    } else if (candidate.contains(':')) {
      baseAddress = 'http://$candidate';
    } else {
      baseAddress = 'http://$candidate:5000';
    }

    if (baseAddress.endsWith('/')) {
      baseAddress = baseAddress.substring(0, baseAddress.length - 1);
    }
  }
}
