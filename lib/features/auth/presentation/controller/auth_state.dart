part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final User? user;

  new({required this.user});
}

final class AuthUnAuthenticated extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthLogoutLoading extends AuthState {}

final class AuthFailure extends AuthState {
  final String message;

  new({required this.message});
}
