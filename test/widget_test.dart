import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_translator_test/features/setting/presentation/controller/theme_cubit.dart';

void main() {
  group('ThemeCubit Tests', () {
    test('initial state is ThemeLoaded with ThemeMode.light', () {
      final themeCubit = ThemeCubit();
      expect(themeCubit.state.themeMode, ThemeMode.light);
      expect(themeCubit.isDarkTheme(), isFalse);
    });

    test('toggleTheme toggles between light and dark modes', () {
      final themeCubit = ThemeCubit();
      themeCubit.toggleTheme(true);
      expect(themeCubit.state.themeMode, ThemeMode.dark);
      expect(themeCubit.isDarkTheme(), isTrue);

      themeCubit.toggleTheme(false);
      expect(themeCubit.state.themeMode, ThemeMode.light);
      expect(themeCubit.isDarkTheme(), isFalse);
    });
  });
}
