import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_constants.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? tokenType,
    int? expiresIn,
    int? refreshExpiresIn,
    List<String>? roles,
  }) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: accessToken);
    await _storage.write(
      key: AppConstants.keyRefreshToken,
      value: refreshToken,
    );
    if (tokenType != null) {
      await _storage.write(key: AppConstants.keyTokenType, value: tokenType);
    }
    if (expiresIn != null) {
      await _storage.write(
        key: AppConstants.keyExpiresIn,
        value: expiresIn.toString(),
      );
    }
    if (refreshExpiresIn != null) {
      await _storage.write(
        key: AppConstants.keyRefreshExpiresIn,
        value: refreshExpiresIn.toString(),
      );
    }
    if (roles != null) {
      await _storage.write(key: AppConstants.keyRoles, value: roles.join(','));
    }
  }

  Future<String?> readAccessToken() =>
      _storage.read(key: AppConstants.keyAccessToken);

  Future<String?> readRefreshToken() =>
      _storage.read(key: AppConstants.keyRefreshToken);

  Future<List<String>> readRoles() async {
    final raw = await _storage.read(key: AppConstants.keyRoles);
    return (raw == null || raw.isEmpty) ? [] : raw.split(',');
  }

  Future<void> clear() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyTokenType);
    await _storage.delete(key: AppConstants.keyExpiresIn);
    await _storage.delete(key: AppConstants.keyRefreshExpiresIn);
    await _storage.delete(key: AppConstants.keyRoles);
  }
}
