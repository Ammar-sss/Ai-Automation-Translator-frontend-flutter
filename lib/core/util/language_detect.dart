String? detectLanguageCode(String text) {
  if (RegExp(r'[ێۆڕڵەڤک]').hasMatch(text)) return 'ckb'; // Sorani
  if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return 'ar';
  if (RegExp(r'[\u0400-\u04FF]').hasMatch(text)) return 'ru';
  return null;
}
