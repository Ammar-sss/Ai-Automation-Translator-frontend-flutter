import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  static final String _keyAccessToken = "access_token";
  static final String _keyRefreshToken = "refresh_token";
  static final String _keyIsAdmin = "is_admin";
  static final String _keyThemeMode = "theme_mode";
  static final String _keyFontFamily = "font_family";
  static final String _keyUserJson = "user_json";

  // In-memory cache to avoid repeated asynchronous platform-channel/KeyStore reads
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  Future<void> saveToken(String accessToken, String refreshToken) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.read(key: _keyAccessToken);
    return _cachedAccessToken;
  }

  Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    _cachedRefreshToken = await _storage.read(key: _keyRefreshToken);
    return _cachedRefreshToken;
  }

  Future<bool> hasAccessToken() async {
    if (_cachedAccessToken != null && _cachedAccessToken!.isNotEmpty)
      return true;
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearToken() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    await Future.wait([
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyIsAdmin),
      _storage.delete(key: _keyUserJson),
    ]);
  }

  Future<bool> getIsAdmin() async {
    final val = await _storage.read(key: _keyIsAdmin);
    return val == 'true';
  }

  Future<void> saveTsAdmin(bool isAdmin) async {
    await _storage.write(key: _keyIsAdmin, value: isAdmin.toString());
  }

  Future<String?> getThemeMode() async {
    return await _storage.read(key: _keyThemeMode);
  }

  Future<void> saveThemeMode(String mode) async {
    await _storage.write(key: _keyThemeMode, value: mode);
  }

  Future<String?> getFontFamily() async {
    return await _storage.read(key: _keyFontFamily);
  }

  Future<void> saveFontFamily(String font) async {
    await _storage.write(key: _keyFontFamily, value: font);
  }

  Future<void> saveUserJson(String userJson) async {
    await _storage.write(key: _keyUserJson, value: userJson);
  }

  Future<String?> getUserJson() async {
    return await _storage.read(key: _keyUserJson);
  }

  Future<void> clearUser() async {
    await _storage.delete(key: _keyUserJson);
  }
}
