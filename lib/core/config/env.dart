import 'package:flutter/foundation.dart';

class Env {
  Env._();

  static final String baseUrl = String.fromEnvironment(
    "BASE_URL",
    defaultValue: "https://ai-automation-translater-backend.onrender.com",
  );

  static final Duration connectTimeout = Duration(seconds: 40);
  static final Duration receiveTimeout = Duration(seconds: 45);

  static const String environment = String.fromEnvironment(
    "ENV",
    defaultValue: kReleaseMode ? "production" : "development",
  );

  static final String sslFingerprint = String.fromEnvironment(
    "SSL_FINGERPRINT",
    defaultValue: "",
  );

  static bool get isProduction => environment == "production";
  static bool get isDevelopment => environment == "development";
}
