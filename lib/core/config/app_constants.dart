class AppConstants {
  AppConstants._();

  //secure storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyTokenType = 'token_type';
  static const String keyExpiresIn = 'expires_in';
  static const String keyRefreshExpiresIn = 'refresh_expires_in';
  static const String keyRoles = 'roles';

  // HTTP / Auth
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  // Validations limits
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 72;
  static const int usernameMaxLength = 50;
  static const int wordTermMinLength = 1;
}
