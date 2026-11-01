import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator/core/models/user.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this._authRepository, required this._tokenStorage})
    : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionRestoredRequested>(_onSessionRestoredRequested);
    on<AuthSessionExpiredRequested>(_onSessionExpiredRequested);
  }

  final AuthRepository _authRepository;
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

      final user = loginResponse.user ?? const User();
      if (loginResponse.user != null) {
        await _tokenStorage.saveUser(user);
      }

      emit(AuthAuthenticated(user: user, roles: loginResponse.roles ?? []));
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(
        const AuthFailure('An unexpected error occurred. Please try again.'),
      );
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
    } catch (_) {
      emit(const AuthFailure('Registration failed. Please try again.'));
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
    } catch (_) {
      // Ignore network errors on logout — clear storage locally anyway
    } finally {
      try {
        await _tokenStorage.clear();
      } catch (_) {}
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSessionRestoredRequested(
    AuthSessionRestoredRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        emit(const AuthUnauthenticated());
        return;
      }

      final roles = await _tokenStorage.readRoles();
      final cachedUser = await _tokenStorage.readUser() ?? const User();

      // Instantly authenticate using cached token and user details
      emit(AuthAuthenticated(user: cachedUser, roles: roles));
    } catch (_) {
      try {
        await _tokenStorage.clear();
      } catch (_) {}
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSessionExpiredRequested(
    AuthSessionExpiredRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _tokenStorage.clear();
    } catch (_) {}
    emit(const AuthUnauthenticated());
  }

  /// Restores previous user session with a guaranteed safety timeout.
  Future<void> restoreSession() async {
    add(const AuthSessionRestoredRequested());
    try {
      await stream
          .firstWhere((state) => state is! AuthInitial && state is! AuthLoading)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        add(const AuthSessionExpiredRequested());
      }
    }
  }
}
