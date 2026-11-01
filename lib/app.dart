import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator/core/network/connectivity_cubit.dart';
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
      builder: (context, child) => Column(
        children: [
          Expanded(child: child!),
          BlocBuilder<ConnectivityCubit, bool>(
            builder: (_, online) => online
                ? const SizedBox.shrink()
                : Material(
                    color: const Color(0xFF33200A),
                    child: SafeArea(
                      top: false,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFF664014), width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.wifi_off_rounded,
                              color: Color(0xFFFFB020),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'No internet connection • Offline mode active',
                              style: TextStyle(
                                color: Color(0xFFFFB020),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
