import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../auth/presentation/controllers/auth_bloc.dart';
import '../../../translation/data/models/ai_response.dart';
import '../../data/models/term.dart';
import '../../domain/repositories/vocabulary_repository.dart';

part 'vocabulary_state.dart';

class VocabularyCubit extends Cubit<VocabularyState> {
  VocabularyCubit(this._repository, {Stream<AuthState>? authStream})
    : super(const VocabularyInitial()) {
    _authSubscription = authStream?.listen((state) {
      if (state is AuthAuthenticated) {
        load();
      } else if (state is AuthUnauthenticated) {
        emit(const VocabularyInitial());
      }
    });
  }

  final VocabularyRepository _repository;
  StreamSubscription? _authSubscription;

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

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
