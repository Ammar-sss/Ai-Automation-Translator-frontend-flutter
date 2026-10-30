import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../translation/data/models/ai_response.dart';
import '../../data/models/term.dart';
import '../../domain/repositories/vocabulary_repository.dart';

part 'vocabulary_state.dart';

class VocabularyCubit extends Cubit<VocabularyState> {
  VocabularyCubit(this._repository) : super(const VocabularyInitial());

  final VocabularyRepository _repository;

  /// Load terms from remote API
  Future<void> load() async {
    emit(const VocabularyLoading());
    try {
      final terms = await _repository.getAllTerms();
      emit(VocabularyLoaded(terms));
    } on ApiException catch (e) {
      emit(VocabularyFailure(e.message));
    }
  }

  /// Save term to remote API, then reload
  Future<void> confirmTermSave(AiResponse aiResponse) async {
    emit(const VocabularyLoading());
    try {
      await _repository.confirmTermSave(aiResponse);
      await load();
    } on ApiException catch (e) {
      emit(VocabularyFailure(e.message));
    }
  }
}
