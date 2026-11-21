import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeLoaded(themeMode: ThemeMode.light));

  void toggleTheme(bool isDark) {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (state.themeMode != mode) {
      emit(ThemeLoaded(themeMode: mode));
    }
  }

  bool isDarkTheme() {
    return state.themeMode == ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    if (state.themeMode != mode) {
      emit(ThemeLoaded(themeMode: mode));
    }
  }
}
