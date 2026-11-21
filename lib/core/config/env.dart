import 'package:smart_translator_test/core/config/secrets.dart';

class Env {
  Env._();

  static final String baseUrl = Secrets.baseUrl;

  static final Duration connectTimeout = Duration(seconds: 40);
  static final Duration receiveTimeout = Duration(seconds: 45);

  static final environment = String.fromEnvironment(
    "ENV",
    defaultValue: "development",
  );

  static bool get isProduction => environment == "production";
  static bool get isDevelopment => environment == "development";
}
