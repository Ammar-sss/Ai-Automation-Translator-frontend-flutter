class Secrets {
  Secrets._();

  static const String elevenLabApi = String.fromEnvironment(
    "ELEVENLABS_API_KEY",
    defaultValue: "",
  );
}
