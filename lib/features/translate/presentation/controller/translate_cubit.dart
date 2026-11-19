import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/features/translate/data/models/ai_response.dart';
import 'package:smart_translator_test/features/translate/data/models/translate_request.dart';
import 'package:smart_translator_test/features/translate/domain/repositories/translate_repository.dart';

part 'translate_state.dart';

class TranslateCubit extends Cubit<TranslateState> {
  final TranslateRepository translateRepository;

  TranslateCubit({required this.translateRepository})
    : super(TranslateInitial());

  Future<void> translate(TranslateRequest translateRequest) async {
    emit(TranslateLoading());
    try {
      final response = await translateRepository.translate(translateRequest);
      if (response.data != null) {
        emit(TranslateLoaded(aiResponse: response.data!));
      } else {
        emit(TranslateFailure(message: response.message));
      }
    } catch (e) {
      final error = e.toString().replaceAll('Exception: ', '');
      emit(TranslateFailure(message: error));
    }
  }

  void reset() {
    emit(TranslateInitial());
  }
}
