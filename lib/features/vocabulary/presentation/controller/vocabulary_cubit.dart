import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/features/translate/data/models/ai_response.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/domain/repositories/vocabulary_repository.dart';

part 'vocabulary_state.dart';

class VocabularyCubit extends Cubit<VocabularyState> {
  final VocabularyRepository vocabularyRepository;

  /// In-memory cache of loaded terms for local list updates.
  List<Term> _cachedTerms = [];

  List<Term> get cachedTerms => _cachedTerms;

  bool isTermSavedOnline(String word) {
    final lower = word.trim().toLowerCase();
    return _cachedTerms.any((t) => t.termWord.trim().toLowerCase() == lower);
  }

  Term? getSavedOnlineTerm(String word) {
    final lower = word.trim().toLowerCase();
    for (final term in _cachedTerms) {
      if (term.termWord.trim().toLowerCase() == lower) {
        return term;
      }
    }
    return null;
  }

  VocabularyCubit(this.vocabularyRepository) : super(VocabularyInitial());

  Term _mapAiResponseToTerm(AiResponse ai) {
    return Term(
      id: 0,
      termWord: ai.termWord,
      termDefinitions: ai.termDefinitions
          .map((d) => TermDefinition(id: 0, definition: d))
          .toSet(),
      termExamples: ai.exampleSentence.isNotEmpty
          ? {Example(id: 0, exampleSentence: ai.exampleSentence)}
          : {},
      exampleDefinitions: ai.exampleDefinition.isNotEmpty
          ? {ExampleDefinition(id: 0, exampleDefinition: ai.exampleDefinition)}
          : {},
    );
  }

  Future<Term?> confirmTermSave(AiResponse aiResponse) async {
    emit(VocabularySaving());
    try {
      final response = await vocabularyRepository.confirmTermSave(aiResponse);
      if (response.data != null) {
        // Update local list instead of re-fetching all terms from the server
        _cachedTerms = [response.data!, ..._cachedTerms];
        try {
          await AppDatabase.instance.updateTerm(response.data!);
        } catch (_) {}
        emit(TermSavedSuccess(term: response.data!));
        return response.data!;
      } else if (response.message.toLowerCase().contains('success') ||
          response.message.toLowerCase().contains('saved')) {
        try {
          final allResponse = await vocabularyRepository.getAllTerms();
          if (allResponse.data != null) {
            _cachedTerms = allResponse.data!;
            final existing = _cachedTerms.firstWhere(
              (t) =>
                  t.termWord.trim().toLowerCase() ==
                  aiResponse.termWord.trim().toLowerCase(),
              orElse: () => _mapAiResponseToTerm(aiResponse),
            );
            if (existing.id > 0) {
              try {
                await AppDatabase.instance.updateTerm(existing);
              } catch (_) {}
            }
            emit(TermSavedSuccess(term: existing));
            return existing;
          }
        } catch (_) {}
        final fallbackTerm = _mapAiResponseToTerm(aiResponse);
        emit(TermSavedSuccess(term: fallbackTerm));
        return fallbackTerm;
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Failed to sync term online';
        emit(VocabularyFailure(message: errorMsg));
        throw Exception(errorMsg);
      }
    } catch (e) {
      final error = e.toString().replaceAll("Exception: ", "");
      if (error.toLowerCase().contains('already exists') ||
          error.contains('409') ||
          error.toLowerCase().contains('success') ||
          error.toLowerCase().contains('saved')) {
        try {
          final allResponse = await vocabularyRepository.getAllTerms();
          if (allResponse.data != null) {
            _cachedTerms = allResponse.data!;
            final existing = _cachedTerms.firstWhere(
              (t) =>
                  t.termWord.trim().toLowerCase() ==
                  aiResponse.termWord.trim().toLowerCase(),
              orElse: () => _mapAiResponseToTerm(aiResponse),
            );
            if (existing.id > 0) {
              try {
                await AppDatabase.instance.updateTerm(existing);
              } catch (_) {}
            }
            emit(TermSavedSuccess(term: existing));
            return existing;
          }
        } catch (_) {}
        // Fallback if getAllTerms fails
        final fallbackTerm = _mapAiResponseToTerm(aiResponse);
        emit(TermSavedSuccess(term: fallbackTerm));
        return fallbackTerm;
      }
      emit(VocabularyFailure(message: error));
      rethrow;
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
        try {
          for (final t in _cachedTerms) {
            if (t.id > 0) {
              await AppDatabase.instance.updateTerm(t);
            }
          }
        } catch (_) {}
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
      await AppDatabase.instance.resetTermCloudStatus(id);
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
