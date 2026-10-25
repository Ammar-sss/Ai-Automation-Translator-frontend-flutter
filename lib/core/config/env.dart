import 'dart:io' show Platform;

class Env {
  Env._();

  static const String _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_definedBaseUrl.isNotEmpty) {
      return _definedBaseUrl;
    }
    if (Platform.isAndroid) {
      return 'http://192.168.1.7:8080'; // Android emulator -> host loopback
    }
    return 'http://localhost:8080';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
