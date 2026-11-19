class ApiEndpoints {
  static const String _v1 = "/api/v1";
  static const String health = "/actuator/health";

  static const String login = "$_v1/auth/login";
  static const String refresh = "$_v1/auth/refresh";
  static const String logout = "$_v1/auth/logout";

  static const String getAllUsers = "$_v1/admin/all";
  static const String deleteUserByEmail = "$_v1/admin";
  static const String getUserByEmail = "$_v1/admin";
  static const String deActivateUserByEmail = "$_v1/admin/deactivate";
  static const String getUserById = "$_v1/admin/{id}";
  static const String deleteUserByID = "$_v1/admin/{id}";
  static const String deActivateUserByID = "$_v1/admin/{id}/deactivate";
  static const String activateUserByID = "$_v1/admin/{id}/activate";
}
