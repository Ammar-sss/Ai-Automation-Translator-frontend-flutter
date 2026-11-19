import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/features/translate/data/models/ai_response.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/domain/repositories/vocabulary_repository.dart';

part 'vocabulary_state.dart';

class VocabularyCubit extends Cubit<VocabularyState> {
  final VocabularyRepository vocabularyRepository;

  /// In-memory cache of loaded terms for local list updates.
  List<Term> _cachedTerms = [];

  VocabularyCubit(this.vocabularyRepository) : super(VocabularyInitial());

  Future<void> confirmTermSave(AiResponse aiResponse) async {
    emit(VocabularySaving());
    try {
      final response = await vocabularyRepository.confirmTermSave(aiResponse);
      if (response.data != null) {
        // Update local list instead of re-fetching all terms from the server
        _cachedTerms = [response.data!, ..._cachedTerms];
        emit(TermSavedSuccess(term: response.data!));
      } else {
        emit(VocabularyFailure(message: response.message));
      }
    } catch (e) {
      final error = e.toString().replaceAll("Exception: ", "");
      emit(VocabularyFailure(message: error));
    }
  }

  Future<void> getTermById(int id) async {
    emit(VocabularyLoading());
    try {
      final response = await vocabularyRepository.getTermById(id);
      if (response.data != null) {
        emit(TermDetailLoaded(term: response.data!));
      } else {
        emit(VocabularyFailure(message: response.message));
      }
    } catch (e) {
      final error = e.toString().replaceAll("Exception: ", "");
      emit(VocabularyFailure(message: error));
    }
  }

  Future<void> getAllTerms() async {
    emit(VocabularyLoading());
    try {
      final response = await vocabularyRepository.getAllTerms();
      if (response.data != null) {
        _cachedTerms = response.data!;
        emit(VocabularyLoaded(terms: _cachedTerms));
      } else {
        emit(VocabularyFailure(message: response.message));
      }
    } catch (e) {
      final error = e.toString().replaceAll("Exception: ", "");
      emit(VocabularyFailure(message: error));
    }
  }

  Future<void> deleteTermById(int id) async {
    // Optimistic delete: remove from local list immediately
    final previousTerms = List<Term>.from(_cachedTerms);
    _cachedTerms.removeWhere((t) => t.id == id);
    emit(VocabularyLoaded(terms: List.unmodifiable(_cachedTerms)));

    try {
      final response = await vocabularyRepository.deleteTermById(id);
      if (response.statusCode != 200 && response.statusCode != 204) {
        // Rollback on failure
        _cachedTerms = previousTerms;
        emit(VocabularyLoaded(terms: _cachedTerms));
        emit(VocabularyFailure(message: response.message));
      }
    } catch (e) {
      // Rollback on error
      _cachedTerms = previousTerms;
      emit(VocabularyLoaded(terms: _cachedTerms));
      final error = e.toString().replaceAll("Exception: ", "");
      emit(VocabularyFailure(message: error));
    }
  }
}
