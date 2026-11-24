import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:smart_translator_test/core/config/env.dart';
import 'package:smart_translator_test/core/network/dio_client.dart';
import 'package:smart_translator_test/core/storage/secure_storage_service.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      values[key] = value;
    } else {
      values.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }
}

void main() {
  group('Env Security & Logging Tests', () {
    test('Env defaults correctly based on build mode', () {
      if (kReleaseMode) {
        expect(Env.environment, equals('production'));
        expect(Env.isProduction, isTrue);
        expect(Env.isDevelopment, isFalse);
      } else {
        expect(Env.environment, equals('development'));
        expect(Env.isDevelopment, isTrue);
      }
    });

    test('DioClient logger interceptor configuration in test mode', () {
      final storage = SecureStorageService(storage: FakeSecureStorage());
      final dioClient = DioClient(storage: storage);

      final hasPrettyLogger = dioClient.dio.interceptors.any(
        (interceptor) => interceptor is PrettyDioLogger,
      );

      // In kDebugMode with development environment, logger is attached.
      // If Env.isDevelopment is false or kDebugMode is false, logger is NOT attached.
      if (kDebugMode && Env.isDevelopment) {
        expect(hasPrettyLogger, isTrue);
      } else {
        expect(
          hasPrettyLogger,
          isFalse,
          reason: 'PrettyDioLogger MUST NOT be attached in non-debug/production builds',
        );
      }
    });
  });
}
