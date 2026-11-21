import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator_test/core/route/app_routes.dart';
import 'package:smart_translator_test/core/widgets/main_shell.dart';
import 'package:smart_translator_test/features/auth/presentation/controller/auth_bloc.dart';
import 'package:smart_translator_test/features/auth/presentation/pages/login_page.dart';
import 'package:smart_translator_test/features/auth/presentation/pages/register_page.dart';
import 'package:smart_translator_test/features/home/presintation/pages/home.dart';
import 'package:smart_translator_test/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:smart_translator_test/features/setting/presentation/pages/setting_page.dart';
import 'package:smart_translator_test/features/translate/presentation/pages/translate_page.dart';
import 'package:smart_translator_test/features/user/presentation/pages/profile_page.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/pages/synced_vocabulary_page.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/pages/vocabulary_page.dart';

class OnRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  OnRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final AuthBloc _authBloc;

  AppRouter({required this._authBloc});

  late final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: OnRouterRefreshStream(_authBloc.stream),
    redirect: (context, state) {
      final authState = _authBloc.state;
      final String currentLocation = state.matchedLocation;

      if (authState is AuthInitial) {
        return AppRoutes.splash;
      }

      final bool isLoggingIn = currentLocation == AppRoutes.login;
      final bool isRegistering = currentLocation == AppRoutes.register;
      final bool isOnBoarding = currentLocation == AppRoutes.onBoarding;
      final bool isSplash = currentLocation == AppRoutes.splash;
      final bool isAuthenticated = authState is AuthAuthenticated;

      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return AppRoutes.login;
      }

      if (isAuthenticated) {
        if (isSplash || isOnBoarding || isLoggingIn || isRegistering) {
          return AppRoutes.home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Or your app logo!
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.onBoarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.setting,
        builder: (context, state) => const SettingPage(),
      ),
      GoRoute(
        path: AppRoutes.vocabularySynced,
        builder: (context, state) => const SyncedVocabularyPage(),
      ),

      // Routes WITH bottom navigation bar (Managed globally by MainShell):
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const Home(),
              ),
            ],
          ),
          // Tab 1: Translate
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.translate,
                builder: (context, state) => const TranslatePage(),
              ),
            ],
          ),
          // Tab 2: Vocabulary
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.vocabulary,
                builder: (context, state) => const VocabularyPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
