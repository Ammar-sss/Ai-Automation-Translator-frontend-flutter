part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthCheckRequested extends AuthEvent {}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  new({required this.email, required this.password});
}

final class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;

  new({required this.email, required this.password, required this.username});
}

final class AuthLogoutRequested extends AuthEvent {}

final class AuthRefreshTokenRequested extends AuthEvent {}
