import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator_test/core/route/app_routes.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/core/widgets/offline_banner.dart';
import 'package:smart_translator_test/core/widgets/server_status_indicator.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/vocabulary_cubit.dart';

import '../../features/auth/presentation/controller/auth_bloc.dart';
import '../../features/user/presentation/controller/user_cubit.dart';

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _titles = ['Home', 'Translate', 'Vocabulary'];

  @override
  void initState() {
    super.initState();
    _fetchProfileIfNeeded();
  }

  void _fetchProfileIfNeeded() {
    final userCubit = context.read<UserCubit>();
    userCubit.getProfile(forceRefresh: true);
    context.read<VocabularyCubit>().getAllTerms();
  }

  String _titleFor(int index) =>
      index < _titles.length ? _titles[index] : 'Smart Translator';

  /// Closes the drawer, then runs [action] with the shell's own context
  /// (the drawer's context is gone once it closes).
  void _closeDrawerThen(VoidCallback action) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) action();
    });
  }

  void _openProfile() =>
      _closeDrawerThen(() => context.push(AppRoutes.profile));

  void _openSettings() =>
      _closeDrawerThen(() => context.push(AppRoutes.setting));

  void _onVocabularySynced() =>
      _closeDrawerThen(() => context.push(AppRoutes.vocabularySynced));

  void _confirmLogout() {
    _closeDrawerThen(() {
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
            actionsAlignment: MainAxisAlignment.end,
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          _fetchProfileIfNeeded();
        } else if (authState is AuthUnAuthenticated) {
          context.read<UserCubit>().reset();
          context.read<VocabularyCubit>().reset();
        }
      },
      child: Scaffold(
        endDrawerEnableOpenDragGesture: true,
        drawerEdgeDragWidth: 32,
        drawerScrimColor: Colors.black.withValues(alpha: 0.38),
        appBar: AppBar(
          centerTitle: false,
          scrolledUnderElevation: 0,
          title: Text(
            _titleFor(shell.currentIndex),
            style: TextStyle(
              fontSize: context.sp(22, min: 20, max: 26),
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            const ServerStatusIndicator(),
            SizedBox(width: context.wp(3)),
            Builder(
              builder: (context) => Tooltip(
                message: 'Account',
                child: InkResponse(
                  radius: 24,
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                  child: const _UserAvatar(radius: 18),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        endDrawer: RepaintBoundary(
          child: _AccountDrawer(
            onProfile: _openProfile,
            onSettings: _openSettings,
            onLogout: _confirmLogout,
            onVocabularySynced: _onVocabularySynced,
          ),
        ),
        body: RepaintBoundary(child: OfflineBanner(child: shell)),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            if (index == 0) {
              context.read<VocabularyCubit>().getAllTerms();
              context.read<FolderCubit>().loadFolders();
            }
            shell.goBranch(index, initialLocation: index == shell.currentIndex);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.translate_outlined),
              selectedIcon: Icon(Icons.translate_rounded),
              label: 'Translate',
            ),
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book_rounded),
              label: 'Vocabulary',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar (rebuilds only when the user changes)
// ---------------------------------------------------------------------------

class _UserAvatar extends StatelessWidget {
  final double radius;
  const _UserAvatar({required this.radius});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<UserCubit, UserState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        final username = state is UserLoaded ? state.user.username : '';
        return CircleAvatar(
          radius: radius,
          backgroundColor: scheme.primaryContainer,
          child: Text(
            username.isNotEmpty ? username[0].toUpperCase() : 'U',
            style: TextStyle(
              fontSize: radius * 0.95,
              fontWeight: FontWeight.w700,
              color: scheme.onPrimaryContainer,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Drawer
// ---------------------------------------------------------------------------

class _AccountDrawer extends StatelessWidget {
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final VoidCallback onVocabularySynced;
  final VoidCallback onLogout;

  const _AccountDrawer({
    required this.onProfile,
    required this.onSettings,
    required this.onLogout,
    required this.onVocabularySynced,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            BlocBuilder<UserCubit, UserState>(
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                final user = state is UserLoaded ? state.user : null;
                return InkWell(
                  onTap: onProfile,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                    child: Row(
                      children: [
                        const _UserAvatar(radius: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.username ?? 'User',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: scheme.outline,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),

            _DrawerItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: onProfile,
            ),
            _DrawerItem(
              icon: Icons.cloud_done_outlined,
              label: 'Synced Vocabulary',
              onTap: onVocabularySynced,
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: onSettings,
            ),
            const Spacer(),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Log out',
              color: scheme.error,
              onTap: onLogout,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
      ),
    );
  }
}
