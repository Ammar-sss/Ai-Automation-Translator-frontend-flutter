import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/storage/secure_storage_service.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SecureStorageService? _storageService;

  ThemeCubit({
    SecureStorageService? storageService,
    ThemeMode initialThemeMode = ThemeMode.light,
  }) : _storageService = storageService,
       super(ThemeLoaded(themeMode: initialThemeMode)) {
    if (storageService != null) {
      _loadSavedTheme();
    }
  }

  Future<void> _loadSavedTheme() async {
    final savedMode = await _storageService?.getThemeMode();
    if (savedMode == 'dark' && state.themeMode != ThemeMode.dark) {
      emit(const ThemeLoaded(themeMode: ThemeMode.dark));
    } else if (savedMode == 'light' && state.themeMode != ThemeMode.light) {
      emit(const ThemeLoaded(themeMode: ThemeMode.light));
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (state.themeMode != mode) {
      emit(ThemeLoaded(themeMode: mode));
      await _storageService?.saveThemeMode(isDark ? 'dark' : 'light');
    }
  }

  bool isDarkTheme() {
    return state.themeMode == ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode != mode) {
      emit(ThemeLoaded(themeMode: mode));
      final modeStr = mode == ThemeMode.dark ? 'dark' : 'light';
      await _storageService?.saveThemeMode(modeStr);
    }
  }
}
