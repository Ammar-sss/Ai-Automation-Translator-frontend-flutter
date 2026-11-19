import '../../../../core/util/api_response.dart';
import '../../data/models/ai_response.dart';
import '../../data/models/translate_request.dart';

abstract class TranslateRepository {
  Future<ApiResponse<AiResponse>> translate(TranslateRequest translateRequest);
}