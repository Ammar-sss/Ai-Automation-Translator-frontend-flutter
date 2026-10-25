class ApiEndpoints {
  ApiEndpoints._();

  static const String _v1 = "/api/v1";

  //Auth
  static const String login = "$_v1/auth/login";
  static const String register = "$_v1/auth/register";
  static const String logout = "$_v1/auth/logout";
  static const String refresh = "$_v1/auth/refresh";

  //User
  static const String me = "$_v1/user/me";

  //Translate
  static const String translate = "$_v1/translate";

  //Vocabulary
  static String getTermByID(int id) => "$_v1/vocabulary/$id";
  static const String getAllTerm = "$_v1/vocabulary";

  static const String addTerm = "$_v1/vocabulary";

  static Set<String> publicPostPaths = {login, register, refresh, logout};

  static bool isPublicPost(String method, String path) {
    return method.toUpperCase() == "POST" && publicPostPaths.contains(path);
  }
}
