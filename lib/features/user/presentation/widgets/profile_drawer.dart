import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator/core/router/route_name.dart';
import 'package:smart_translator/features/auth/presentation/controllers/auth_bloc.dart';
import 'package:smart_translator/features/user/domain/repositories/user_repository.dart';
import 'package:smart_translator/features/user/presentation/controllers/user_cubit.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  static void open(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ProfileDrawer',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => BlocProvider(
        create: (context) =>
            UserCubit(context.read<UserRepository>())..loadProfile(),
        child: const Align(
          alignment: Alignment.centerRight,
          child: ProfileDrawer(),
        ),
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const drawerBackground = Color(0xFF14151B);
    const cardColor = Color(0xFF1E1F2A);
    const borderColor = Color(0xFF282935);
    const primaryOrange = Color(0xFFFF5A2C);
    const successGreen = Color(0xFF4AE183);
    const textMuted = Color(0xFFAB8981);
    const textSlate = Color(0xFFE4BEB5);

    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: screenWidth * 0.88,
        height: double.infinity,
        color: drawerBackground,
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            final userName =
                (state is UserLoaded &&
                    state.user.username != null &&
                    state.user.username!.isNotEmpty)
                ? state.user.username!
                : 'Linh Tran';
            final userEmail =
                (state is UserLoaded &&
                    state.user.email != null &&
                    state.user.email!.isNotEmpty)
                ? state.user.email!
                : 'linh.tran@workspace.io';
            final userInitial = userName.isNotEmpty
                ? userName[0].toUpperCase()
                : 'L';

            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Profile Header Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar with Green Dot
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: primaryOrange,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  userInitial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: successGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: drawerBackground,
                                  width: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        // Name, Email, Sync Status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF381F18),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: primaryOrange.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'PRO',
                                      style: TextStyle(
                                        color: primaryOrange,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userEmail,
                                style: const TextStyle(
                                  color: textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: successGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'All terms synced',
                                    style: TextStyle(
                                      color: successGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Close Button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cardColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Body Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Single Stats Card: TERMS LEARNED (842)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'TERMS LEARNED',
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.auto_stories_rounded,
                                      color: primaryOrange,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '842',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section 1: ACCOUNT
                          const Text(
                            'ACCOUNT',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _MenuTile(
                            icon: Icons.manage_accounts_rounded,
                            title: 'Profile',
                            onTap: () {
                              context.push(RouteName.profile);
                            },
                          ),
                          const SizedBox(height: 24),

                          // Section 2: PREFERENCES
                          const Text(
                            'PREFERENCES',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _MenuTile(
                            icon: Icons.tune_rounded,
                            title: 'Settings',
                            onTap: () {},
                          ),
                          const SizedBox(height: 24),

                          // Section 3: APPLICATION
                          const Text(
                            'APPLICATION',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _MenuTile(
                            icon: Icons.auto_awesome_rounded,
                            title: 'About AI Translator',
                            badge: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF282935),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'v2.4.0',
                                style: TextStyle(
                                  color: textSlate,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {},
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Log Out Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A0E12),
                          foregroundColor: const Color(0xFFFF6B6B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<AuthBloc>().add(
                            const AuthLogoutRequested(),
                          );
                        },
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF1E1F2A);
    const borderColor = Color(0xFF282935);
    const textMuted = Color(0xFFAB8981);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF282935),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white70, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
            if (badge != null) ...[badge!, const SizedBox(width: 8)],
            const Icon(Icons.chevron_right_rounded, color: textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
