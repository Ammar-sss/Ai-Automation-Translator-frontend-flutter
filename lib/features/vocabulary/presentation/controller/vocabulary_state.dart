part of 'vocabulary_cubit.dart';

@immutable
sealed class VocabularyState {}

final class VocabularyInitial extends VocabularyState {}
final class VocabularyLoading extends VocabularyState {}

/// Lightweight loading state for save/delete operations (doesn't replace the list).
final class VocabularySaving extends VocabularyState {}

final class VocabularyLoaded extends VocabularyState {
  final List<Term> terms;

  VocabularyLoaded({required this.terms});
}
final class TermDetailLoaded extends VocabularyState {
  final Term term;

  TermDetailLoaded({required this.term});
}
final class TermSavedSuccess extends VocabularyState {
  final Term term;

  TermSavedSuccess({required this.term});
}
final class VocabularyFailure extends VocabularyState {
  final String message;

  VocabularyFailure({required this.message});
}
