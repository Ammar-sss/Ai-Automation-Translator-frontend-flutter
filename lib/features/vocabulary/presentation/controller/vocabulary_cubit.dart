import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/save_term_request.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/domain/repositories/vocabulary_repository.dart';

part 'vocabulary_state.dart';

class VocabularyCubit extends Cubit<VocabularyState> {
  final VocabularyRepository vocabularyRepository;

  /// In-memory cache of loaded terms for local list updates.
  List<Term> _cachedTerms = [];

  List<Term> get cachedTerms => _cachedTerms;

  bool isTermSavedOnline(
    String word, {
    String? sourceLanguage,
    String? targetLanguage,
  }) {
    final lower = word.trim().toLowerCase();
    return _cachedTerms.any((t) {
      if (t.termWord.trim().toLowerCase() != lower) return false;
      if (sourceLanguage != null && sourceLanguage.isNotEmpty) {
        if (t.sourceLanguage == null || t.sourceLanguage != sourceLanguage) {
          return false;
        }
      }
      if (targetLanguage != null && targetLanguage.isNotEmpty) {
        if (t.targetLanguage == null || t.targetLanguage != targetLanguage) {
          return false;
        }
      }
      return true;
    });
  }

  Term? getSavedOnlineTerm(
    String word, {
    String? sourceLanguage,
    String? targetLanguage,
  }) {
    final lower = word.trim().toLowerCase();
    for (final term in _cachedTerms) {
      if (term.termWord.trim().toLowerCase() != lower) continue;
      if (sourceLanguage != null && sourceLanguage.isNotEmpty) {
        if (term.sourceLanguage == null ||
            term.sourceLanguage != sourceLanguage) {
          continue;
        }
      }
      if (targetLanguage != null && targetLanguage.isNotEmpty) {
        if (term.targetLanguage == null ||
            term.targetLanguage != targetLanguage) {
          continue;
        }
      }
      return term;
    }
    return null;
  }

  VocabularyCubit(this.vocabularyRepository) : super(VocabularyInitial());

  Term _mapSaveRequestToTerm(SaveTermRequest req) {
    return Term(
      id: 0,
      termWord: req.termWord,
      sourceLanguage: req.sourceLanguage.backendValue,
      targetLanguage: req.targetLanguage.backendValue,
      termDefinitions: req.termDefinitions
          .map((d) => TermDefinition(id: 0, definition: d))
          .toSet(),
      termExamples: req.exampleSentence.isNotEmpty
          ? {Example(id: 0, exampleSentence: req.exampleSentence)}
          : {},
      exampleDefinitions: req.exampleDefinition.isNotEmpty
          ? {ExampleDefinition(id: 0, exampleDefinition: req.exampleDefinition)}
          : {},
    );
  }

  Future<Term?> confirmTermSave(SaveTermRequest saveTermRequest) async {
    emit(VocabularySaving());
    try {
      final response = await vocabularyRepository.confirmTermSave(
        saveTermRequest,
      );
      if (response.data != null) {
        // Ensure sourceLanguage and targetLanguage are populated even if backend DTO omits them
        final serverTerm = response.data!;
        final termWithLangs = Term(
          id: serverTerm.id,
          termWord: serverTerm.termWord,
          sourceLanguage:
              (serverTerm.sourceLanguage != null &&
                  serverTerm.sourceLanguage!.isNotEmpty)
              ? serverTerm.sourceLanguage
              : saveTermRequest.sourceLanguage.backendValue,
          targetLanguage:
              (serverTerm.targetLanguage != null &&
                  serverTerm.targetLanguage!.isNotEmpty)
              ? serverTerm.targetLanguage
              : saveTermRequest.targetLanguage.backendValue,
          termDefinitions: serverTerm.termDefinitions,
          termExamples: serverTerm.termExamples,
          exampleDefinitions: serverTerm.exampleDefinitions,
        );

        // Update local list instead of re-fetching all terms from the server
        _cachedTerms = [termWithLangs, ..._cachedTerms];
        try {
          await AppDatabase.instance.updateTerm(termWithLangs);
        } catch (_) {}
        emit(TermSavedSuccess(term: termWithLangs));
        return termWithLangs;
      } else if (response.message.toLowerCase().contains('success') ||
          response.message.toLowerCase().contains('saved')) {
        try {
          final allResponse = await vocabularyRepository.getAllTerms();
          if (allResponse.data != null) {
            _cachedTerms = allResponse.data!;
            final existing = _cachedTerms.firstWhere(
              (t) =>
                  t.termWord.trim().toLowerCase() ==
                      saveTermRequest.termWord.trim().toLowerCase() &&
                  (t.targetLanguage == null ||
                      t.targetLanguage ==
                          saveTermRequest.targetLanguage.backendValue),
              orElse: () => _mapSaveRequestToTerm(saveTermRequest),
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
        final fallbackTerm = _mapSaveRequestToTerm(saveTermRequest);
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
                      saveTermRequest.termWord.trim().toLowerCase() &&
                  (t.targetLanguage == null ||
                      t.targetLanguage ==
                          saveTermRequest.targetLanguage.backendValue),
              orElse: () => _mapSaveRequestToTerm(saveTermRequest),
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
        final fallbackTerm = _mapSaveRequestToTerm(saveTermRequest);
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
