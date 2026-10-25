part of 'translate_cubit.dart';

@immutable
sealed class TranslateState {
  const TranslateState();
}

final class TranslateInitial extends TranslateState {
  const TranslateInitial();
}

final class TranslateLoading extends TranslateState {
  const TranslateLoading();
}

final class TranslateSuccess extends TranslateState {
  const TranslateSuccess(this.result);
  final AiResponse result;
}

final class TranslateFailure extends TranslateState {
  const TranslateFailure(this.message);
  final String message;
}
