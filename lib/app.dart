// TODO: Practice building app.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator/core/theme/app_theme.dart';

class SmartTranslatorApp extends StatelessWidget {
  const SmartTranslatorApp({super.key, required this._router});

  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'smart translator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
    );
  }
}
