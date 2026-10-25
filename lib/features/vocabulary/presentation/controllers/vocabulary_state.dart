part of 'vocabulary_cubit.dart';

sealed class VocabularyState {
  const VocabularyState();
}

final class VocabularyInitial extends VocabularyState {
  const VocabularyInitial();
}

final class VocabularyLoading extends VocabularyState {
  const VocabularyLoading();
}

final class VocabularyLoaded extends VocabularyState {
  const VocabularyLoaded(this.terms);

  final List<Term> terms;
}

final class VocabularyFailure extends VocabularyState {
  const VocabularyFailure(this.message);

  final String message;
}
