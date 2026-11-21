import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_translator_test/core/storage/secure_storage_service.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> values = {};
  int readCount = 0;
  int writeCount = 0;
  int deleteCount = 0;

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    readCount++;
    return values[key];
  }

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
    writeCount++;
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
    deleteCount++;
    values.remove(key);
  }
}

void main() {
  group('SecureStorageService Performance Cache Tests', () {
    late FakeSecureStorage fakeStorage;
    late SecureStorageService service;

    setUp(() {
      fakeStorage = FakeSecureStorage();
      service = SecureStorageService(storage: fakeStorage);
    });

    test('saveToken populates in-memory cache and avoids disk read', () async {
      await service.saveToken('access_123', 'refresh_456');

      // The write was dispatched to underlying storage
      expect(fakeStorage.writeCount, 2);

      // Subsequent getAccessToken should read from cache directly without calling storage.read
      final token = await service.getAccessToken();
      expect(token, 'access_123');
      expect(
        fakeStorage.readCount,
        0,
        reason: 'Cache hit should not trigger disk/keystore read',
      );

      final refreshToken = await service.getRefreshToken();
      expect(refreshToken, 'refresh_456');
      expect(
        fakeStorage.readCount,
        0,
        reason: 'Cache hit should not trigger disk/keystore read',
      );
    });

    test('hasAccessToken uses in-memory cache without storage.read', () async {
      await service.saveToken('access_123', 'refresh_456');

      final hasToken = await service.hasAccessToken();
      expect(hasToken, isTrue);
      expect(fakeStorage.readCount, 0);
    });

    test('clearToken invalidates in-memory cache', () async {
      await service.saveToken('access_123', 'refresh_456');
      await service.clearToken();

      expect(await service.hasAccessToken(), isFalse);
      expect(await service.getAccessToken(), isNull);
    });
  });
}
