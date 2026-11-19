part of 'translate_cubit.dart';

@immutable
sealed class TranslateState {}

final class TranslateInitial extends TranslateState {}

final class TranslateLoading extends TranslateState {}

final class TranslateLoaded extends TranslateState {
  final AiResponse aiResponse;

  new({required this.aiResponse});
}

final class TranslateFailure extends TranslateState {
  final String message;

  new({required this.message});
}
