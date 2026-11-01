import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_translator/core/models/user.dart';

import '../config/app_constants.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _keyOnboardingSeen = 'has_seen_onboarding';
  static const _keyUserId = 'cached_user_id';
  static const _keyUsername = 'cached_username';
  static const _keyEmail = 'cached_email';

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

  Future<void> saveUser(User user) async {
    if (user.id != null) {
      await _storage.write(key: _keyUserId, value: user.id.toString());
    }
    if (user.username != null) {
      await _storage.write(key: _keyUsername, value: user.username);
    }
    if (user.email != null) {
      await _storage.write(key: _keyEmail, value: user.email);
    }
  }

  Future<User?> readUser() async {
    final rawId = await _storage.read(key: _keyUserId);
    final username = await _storage.read(key: _keyUsername);
    final email = await _storage.read(key: _keyEmail);

    if (rawId == null && username == null && email == null) {
      return null;
    }

    return User(
      id: rawId != null ? int.tryParse(rawId) : null,
      username: username,
      email: email,
      enabled: true,
    );
  }

  Future<String?> readAccessToken() =>
      _storage.read(key: AppConstants.keyAccessToken);

  Future<String?> readRefreshToken() =>
      _storage.read(key: AppConstants.keyRefreshToken);

  Future<List<String>> readRoles() async {
    final raw = await _storage.read(key: AppConstants.keyRoles);
    return (raw == null || raw.isEmpty) ? [] : raw.split(',');
  }

  Future<bool> hasSeenOnboarding() async {
    final val = await _storage.read(key: _keyOnboardingSeen);
    return val == 'true';
  }

  Future<void> setOnboardingSeen() async {
    await _storage.write(key: _keyOnboardingSeen, value: 'true');
  }

  Future<void> clear() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyTokenType);
    await _storage.delete(key: AppConstants.keyExpiresIn);
    await _storage.delete(key: AppConstants.keyRefreshExpiresIn);
    await _storage.delete(key: AppConstants.keyRoles);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keyEmail);
  }
}
