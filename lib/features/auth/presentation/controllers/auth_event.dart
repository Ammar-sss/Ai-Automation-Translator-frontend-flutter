part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {
  const AuthEvent();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested(this.email, this.password);

  final String email;
  final String password;
}

final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested(this.username, this.email, this.password);

  final String username;
  final String email;
  final String password;
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthSessionRestoredRequested extends AuthEvent {
  const AuthSessionRestoredRequested();
}

/// Triggered when the refresh token expires or is rejected (HTTP 401).
final class AuthSessionExpiredRequested extends AuthEvent {
  const AuthSessionExpiredRequested();
}
