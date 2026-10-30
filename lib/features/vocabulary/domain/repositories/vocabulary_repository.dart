import 'package:smart_translator/core/database/app_database.dart';
import '../../../translation/data/models/ai_response.dart';
import '../../data/models/term.dart';

/// Abstract domain contract for Vocabulary operations.
abstract interface class VocabularyRepository {
  Future<void> confirmTermSave(AiResponse aiResponse);
  Future<int> saveTermLocally(AiResponse r, int userId);
  Future<List<Term>> getAllTerms();
  Future<Term> getTermByID(int id);
  Future<List<LocalTerm>> getAllLocalTerms();
  Future<LocalTerm?> getLocalTermById(int id);
  Stream<List<LocalTerm>> watchLocalTerms();
}
