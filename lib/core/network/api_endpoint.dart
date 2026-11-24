class ApiEndpoint {
  static const String _v1 = "/api/v1";
  static const String health = "/actuator/health";

  static const String login = "$_v1/auth/login";
  static const String register = "$_v1/auth/register";
  static const String logout = "$_v1/auth/logout";
  static const String refresh = "$_v1/auth/refresh";

  static const String profile = "$_v1/user/me";

  static const String translate = "$_v1/translate";
  static const String tts = "$_v1/tts";

  static const String confirmTermSave = "$_v1/vocabulary";
  static const String getTermById = "$_v1/vocabulary/{id}";
  static const String getAllTerms = "$_v1/vocabulary";
  static const String deleteTermById = "$_v1/vocabulary/{id}";
}
