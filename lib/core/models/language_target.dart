import 'package:json_annotation/json_annotation.dart';

enum LanguageTarget {
  @JsonValue("ARABIC")
  arabic,

  @JsonValue("ENGLISH")
  english,

  @JsonValue("FRENCH")
  french,

  @JsonValue("GERMANY")
  germany,

  @JsonValue("ITALIAN")
  italy,

  @JsonValue("SPANISH")
  spanish,

  @JsonValue("RUSSIAN")
  russian,

  @JsonValue("KURDISH_SORANI")
  kurdishSorani,

  @JsonValue("KURDISH_KURMANJI")
  kurdishKurmanji,

  @JsonValue("DUTCH")
  dutch,
}
