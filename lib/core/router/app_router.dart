import 'package:go_router/go_router.dart';
import 'package:smart_translator/core/router/go_router_refresh_stream.dart';
import 'package:smart_translator/core/router/route_name.dart';
import 'package:smart_translator/core/widgets/main_wrapper_page.dart';
import 'package:smart_translator/features/auth/presentation/pages/login_page.dart';
import 'package:smart_translator/features/auth/presentation/pages/register_page.dart';
import 'package:smart_translator/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:smart_translator/features/user/presentation/pages/profile_page.dart';
import 'package:smart_translator/features/vocabulary/presentation/pages/vocabulary_page.dart';

import '../../features/auth/presentation/controllers/auth_bloc.dart';

GoRouter createRouter(AuthBloc authBloc, {required bool hasSeenOnboarding}) {
  return GoRouter(
    initialLocation: hasSeenOnboarding ? RouteName.login : RouteName.onboarding,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final isSignIn = authBloc.state is AuthAuthenticated;
      final location = state.matchedLocation;
      final isAuthRoute =
          location == RouteName.login ||
          location == RouteName.register ||
          location == RouteName.onboarding;

      // 1. Unauthenticated users cannot access protected screens
      if (!isSignIn && !isAuthRoute) return RouteName.login;

      // 2. When login succeeds (isSignIn == true), automatically redirect from /login to Home (/)!
      if (isSignIn && isAuthRoute) return RouteName.home;

      return null;
    },
    routes: [
      GoRoute(
        path: RouteName.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteName.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteName.home,
        builder: (context, state) => const MainWrapperPage(),
      ),
      GoRoute(
        path: RouteName.vocabulary,
        builder: (context, state) => const VocabularyPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RouteName.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
    ],
  );
}
