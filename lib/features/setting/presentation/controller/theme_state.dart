part of 'theme_cubit.dart';

@immutable
sealed class ThemeState {
  final ThemeMode themeMode;
  const ThemeState({required this.themeMode});
}

final class ThemeLoaded extends ThemeState {
  const ThemeLoaded({required super.themeMode});
}
