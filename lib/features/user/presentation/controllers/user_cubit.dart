import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator/core/models/user.dart';
import '../../domain/repositories/user_repository.dart';

import '../../../../core/errors/api_exception.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this._userRepository) : super(const UserInitial());

  final UserRepository _userRepository;

  Future<void> loadProfile() async {
    emit(const UserLoading());
    try {
      final user = await _userRepository.getProfile();
      emit(UserLoaded(user));
    } on ApiException catch (e) {
      emit(UserError(e.message));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> updateProfile(User user) async {
    emit(const UserLoading());
    try {
      final updatedUser = await _userRepository.updateProfile(user);
      emit(UserLoaded(updatedUser));
    } on ApiException catch (e) {
      emit(UserError(e.message));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
