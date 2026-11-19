import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/features/user/data/models/update_user_profile.dart';
import 'package:smart_translator_test/features/user/data/models/user.dart';
import 'package:smart_translator_test/features/user/domain/repositories/user_repository.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository userRepository;

  UserCubit({required this.userRepository}) : super(UserInitial());

  Future<void> getProfile({bool forceRefresh = false}) async {
    emit(UserLoading());
    try {
      final response = await userRepository.getProfile(
        forceRefresh: forceRefresh,
      );
      if (response.data != null) {
        emit(UserLoaded(user: response.data!));
      } else {
        emit(UserFailure(message: response.message));
      }
    } catch (e) {
      final error = e.toString().replaceAll("Exception: ", "");
      emit(UserFailure(message: error));
    }
  }

  Future<void> updateProfile(UpdateUserProfile updateUserProfile) async {
    emit(UserLoading());
    try {
      final response = await userRepository.updateProfile(updateUserProfile);
      if (response.data != null) {
        emit(UserLoaded(user: response.data!));
      } else {
        emit(UserFailure(message: response.message));
      }
    } catch (e) {
      final error = e.toString().replaceAll("Exception: ", "");
      emit(UserFailure(message: error));
    }
  }
}
