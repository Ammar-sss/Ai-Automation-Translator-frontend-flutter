import '../../../../core/util/api_response.dart';
import '../../../translate/data/models/ai_response.dart';
import '../../data/models/term.dart';

abstract class VocabularyRepository {
  Future<ApiResponse<Term>> confirmTermSave(AiResponse aiResponse);
  Future<ApiResponse<Term>> getTermById(int id);
  Future<ApiResponse<List<Term>>> getAllTerms();
  Future<ApiResponse<void>> deleteTermById(int id);
}
