import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator/core/models/user.dart';
import 'package:smart_translator/features/user/data/repositories/user_repository.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/token_storage.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._authRepository,
    required this._userRepository,
    required this._tokenStorage,
  }) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionRestoredRequested>(_onSessionRestoredRequested);
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final TokenStorage _tokenStorage;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final loginResponse = await _authRepository.login(
        event.email,
        event.password,
      );

      await _tokenStorage.saveTokens(
        accessToken: loginResponse.token ?? '',
        refreshToken: loginResponse.refreshToken ?? '',
        expiresIn: loginResponse.expiresIn,
        refreshExpiresIn: loginResponse.refreshExpiresIn,
        roles: loginResponse.roles,
        tokenType: loginResponse.tokenType,
      );

      emit(
        AuthAuthenticated(
          user: loginResponse.user ?? const User(),
          roles: loginResponse.roles ?? [],
        ),
      );
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.register(
        event.username,
        event.email,
        event.password,
      );

      emit(AuthRegistered(user));
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authRepository.logout(refreshToken);
      }
    } on ApiException {
      // Ignore network errors on logout — clear storage locally anyway
    } finally {
      await _tokenStorage.clear();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSessionRestoredRequested(
    AuthSessionRestoredRequested event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final user = await _userRepository.getProfile();
      emit(
        AuthAuthenticated(user: user, roles: await _tokenStorage.readRoles()),
      );
    } on ApiException {
      await _tokenStorage.clear();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> restoreSession() async {
    add(const AuthSessionRestoredRequested());
    await stream.firstWhere(
      (state) => state is! AuthInitial && state is! AuthLoading,
    );
  }
}
