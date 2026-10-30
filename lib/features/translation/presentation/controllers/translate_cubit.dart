import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator/core/models/language_target.dart';

import '../../../../core/errors/api_exception.dart';
import '../../data/models/ai_response.dart';
import '../../domain/repositories/translate_repository.dart';

part 'translate_state.dart';

class TranslateCubit extends Cubit<TranslateState> {
  TranslateCubit(this._translateRepository) : super(const TranslateInitial());

  final TranslateRepository _translateRepository;

  Future<void> translate(
    String termWord,
    LanguageTarget sourceLanguage,
    LanguageTarget targetLanguage,
  ) async {
    if (termWord.trim().isEmpty) return;

    emit(const TranslateLoading());
    try {
      final result = await _translateRepository.translate(
        termWord.trim(),
        sourceLanguage,
        targetLanguage,
      );
      emit(TranslateSuccess(result));
    } on ApiException catch (e) {
      emit(TranslateFailure(e.message));
    }
  }
}
