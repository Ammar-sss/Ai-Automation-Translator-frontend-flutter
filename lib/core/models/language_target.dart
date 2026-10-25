enum LanguageTarget {
  ar('AR'),
  en('EN'),
  es('ES'),
  fr('FR');

  const LanguageTarget(this.code);

  final String code;

  static LanguageTarget fromCode(String? code) {
    return values.firstWhere(
      (e) => e.code == code,
      orElse: () => LanguageTarget.en,
    );
  }
}
