import '../../../../core/util/api_response.dart';
import '../../data/models/save_term_request.dart';
import '../../data/models/term.dart';

abstract class VocabularyRepository {
  Future<ApiResponse<Term>> confirmTermSave(SaveTermRequest saveTermRequest);
  Future<ApiResponse<Term>> getTermById(int id);
  Future<ApiResponse<List<Term>>> getAllTerms();
  Future<ApiResponse<void>> deleteTermById(int id);
}
