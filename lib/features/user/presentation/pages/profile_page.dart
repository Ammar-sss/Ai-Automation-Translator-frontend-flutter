import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_translator_test/core/route/app_routes.dart';
import 'package:smart_translator_test/features/auth/presentation/controller/auth_bloc.dart';
import 'package:smart_translator_test/features/user/presentation/widgets/edit_profile_sheet.dart';
import 'package:smart_translator_test/features/user/presentation/widgets/profile_header.dart';
import 'package:smart_translator_test/features/user/presentation/widgets/setting_group.dart';
import 'package:smart_translator_test/features/user/presentation/widgets/setting_switch.dart';
import 'package:smart_translator_test/features/user/presentation/widgets/setting_title.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/vocabulary_cubit.dart';

import '../../../setting/presentation/controller/theme_cubit.dart';
import '../controller/user_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Fetch latest profile status and vocabulary terms when ProfilePage opens
    context.read<UserCubit>().getProfile(forceRefresh: true);
    context.read<VocabularyCubit>().getAllTerms();
  }

  // ----- actions -----------------------------------------------------------

  Future<void> _editProfile(String name, String email) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => EditProfileSheet(name: name),
    );
    if (saved == true) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Profile updated'),
          ),
        );
    }
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.help_outline_rounded),
        title: const Text('Help & support'),
        content: const Text(
          'For assistance, contact support@smarttranslator.com or check the FAQ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy() {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Translator',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.translate_rounded, size: 48),
      children: const [
        Text(
          'Your privacy is important to us. All translations are securely processed.',
        ),
      ],
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.logout_rounded, color: scheme.error),
          title: const Text('Log out?'),
          content: const Text(
            'You’ll need to sign in again to use Smart Translator.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );
  }

  // ----- build -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('No new notifications'),
                  ),
                );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          final isUserLoading =
              userState is UserLoading || userState is UserInitial;
          final user = userState is UserLoaded ? userState.user : null;
          final username =
              user?.username ?? (isUserLoading ? 'Loading Username' : 'User');
          final email =
              user?.email ?? (isUserLoading ? 'user@placeholder.com' : '');
          final isEnabled = user?.enabled ?? true;

          return BlocBuilder<VocabularyCubit, VocabularyState>(
            builder: (context, vocabState) {
              final isVocabLoading =
                  vocabState is VocabularyLoading ||
                  vocabState is VocabularyInitial;
              final isLoading = isUserLoading || isVocabLoading;

              final termsCount = vocabState is VocabularyLoaded
                  ? '${vocabState.terms.length} terms'
                  : (isVocabLoading ? '--- terms' : '0 terms');

              return RefreshIndicator(
                onRefresh: () {
                  final userCubit = context.read<UserCubit>();
                  final vocabularyCubit = context.read<VocabularyCubit>();
                  return Future.wait([
                    userCubit.getProfile(forceRefresh: true),
                    vocabularyCubit.getAllTerms(),
                  ]);
                },
                child: Skeletonizer(
                  enabled: isLoading,
                  effect: ShimmerEffect(
                    baseColor: Colors.white.withValues(alpha: 0.15),
                    highlightColor: Colors.white.withValues(alpha: 0.35),
                  ),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      ProfileHeader(
                        username: username,
                        email: email,
                        isEnabled: isEnabled,
                        onEdit: () => _editProfile(username, email),
                      ),
                      const SizedBox(height: 28),

                      SettingsGroup(
                        title: 'Preferences',
                        children: [
                          SettingTile(
                            icon: Icons.bookmark_outline_rounded,
                            title: 'Number of terms',
                            subtitle: termsCount,
                            onTap: () {
                              context.go(AppRoutes.vocabulary);
                            },
                          ),
                          BlocSelector<ThemeCubit, ThemeState, bool>(
                            selector: (state) =>
                                state.themeMode == ThemeMode.dark,
                            builder: (context, isDark) {
                              return SettingSwitch(
                                icon: Icons.dark_mode_outlined,
                                title: 'Dark theme',
                                subtitle: 'Switch between light and dark',
                                value: isDark,
                                onChanged: (v) =>
                                    context.read<ThemeCubit>().toggleTheme(v),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SettingsGroup(
                        title: 'Support',
                        children: [
                          SettingTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & support',
                            subtitle: 'FAQ and contact',
                            onTap: _showHelp,
                          ),
                          SettingTile(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy policy',
                            subtitle: 'Terms and privacy',
                            onTap: _showPrivacy,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Log out
                      Material(
                        color: scheme.errorContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          leading: Icon(
                            Icons.logout_rounded,
                            color: scheme.error,
                          ),
                          title: Text(
                            'Log out',
                            style: TextStyle(
                              color: scheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onTap: _confirmLogout,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
