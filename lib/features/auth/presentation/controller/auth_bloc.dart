import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/storage/secure_storage_service.dart';
import 'package:smart_translator_test/features/auth/data/models/login_request.dart';
import 'package:smart_translator_test/features/auth/data/models/refresh_token_request.dart';
import 'package:smart_translator_test/features/auth/data/models/register_request.dart';
import 'package:smart_translator_test/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_translator_test/features/user/data/models/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SecureStorageService storageService;

  AuthBloc({required this.authRepository, required this.storageService})
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_authCheckRequested);
    on<AuthLoginRequested>(_authLoginRequested);
    on<AuthRegisterRequested>(_authRegisterRequested);
    on<AuthLogoutRequested>(_authLogoutRequested);
    on<AuthRefreshTokenRequested>(_authRefreshTokenRequested);
  }

  Future<void> _authCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasToken = await storageService.hasAccessToken();
    if (hasToken) {
      emit(AuthAuthenticated(user: null));
    } else {
      emit(AuthUnAuthenticated());
    }
  }

  Future<void> _authLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.login(
        LoginRequest(email: event.email, password: event.password),
      );
      if (response.user != null) {
        await storageService.saveUserJson(jsonEncode(response.user!.toJson()));
      }
      emit(AuthAuthenticated(user: response.user));
    } catch (e) {
      final error = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(message: error));
    }
  }

  Future<void> _authRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.register(
        RegisterRequest(
          username: event.username,
          email: event.email,
          password: event.password,
        ),
      );
      emit(AuthRegistrationSuccess());
    } catch (e) {
      final error = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(message: error));
    }
  }

  Future<void> _authLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLogoutLoading());
    try {
      final refreshToken = await storageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await authRepository.logout(
          RefreshTokenRequest(refreshToken: refreshToken),
        );
      }
    } catch (_) {
    } finally {
      await storageService.clearToken();
      emit(AuthUnAuthenticated());
    }
  }

  Future<void> _authRefreshTokenRequested(
    AuthRefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final refreshToken = await storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        emit(AuthUnAuthenticated());
        return;
      }
      final response = await authRepository.refreshToken(
        RefreshTokenRequest(refreshToken: refreshToken),
      );
      emit(AuthAuthenticated(user: response.user));
    } catch (e) {
      final error = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(message: error));
      emit(AuthUnAuthenticated());
    }
  }
}
