part of 'user_cubit.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}
final class UserLoading extends UserState {}
final class UserLoaded extends UserState {
  final User user;

  new({required this.user});
}
final class UserFailure extends UserState {
  final String message;

  new({required this.message});
}
