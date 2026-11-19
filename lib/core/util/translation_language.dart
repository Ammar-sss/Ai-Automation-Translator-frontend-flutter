import 'package:freezed_annotation/freezed_annotation.dart';

enum TranslationLanguage {
  @JsonValue("ARABIC")
  arabic("ARABIC"),

  @JsonValue("ENGLISH")
  english("ENGLISH"),

  @JsonValue("FRENCH")
  french("FRENCH"),

  @JsonValue("GERMANY")
  germany("GERMANY"),

  @JsonValue("ITALIAN")
  italy("ITALIAN"),

  @JsonValue("SPANISH")
  spanish("SPANISH"),

  @JsonValue("RUSSIAN")
  russian("RUSSIAN"),

  @JsonValue("KURDISH_SORANI")
  kurdishSorani("KURDISH_SORANI"),

  @JsonValue("KURDISH_KURMANJI")
  kurdishKurmanji("KURDISH_KURMANJI"),

  @JsonValue("DUTCH")
  dutch("DUTCH");

  final String backendValue;
  const TranslationLanguage(this.backendValue);

  /// Display label for UI (e.g. "English", "KurdishSorani")
  String get displayName => name[0].toUpperCase() + name.substring(1);
}
