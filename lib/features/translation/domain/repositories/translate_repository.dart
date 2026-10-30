import 'package:smart_translator/core/models/language_target.dart';
import '../../data/models/ai_response.dart';

/// Abstract domain contract for translation.
abstract interface class TranslateRepository {
  Future<AiResponse> translate(
    String termWord,
    LanguageTarget sourceLanguage,
    LanguageTarget targetLanguage,
  );
}
