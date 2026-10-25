import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_translator/features/auth/presentation/controllers/auth_bloc.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  /// Helper method to open the slide-out Profile drawer from any screen.
  static void open(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ProfileDrawer',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) =>
          const Align(alignment: Alignment.centerRight, child: ProfileDrawer()),
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
    const cardColor = Color(0xFF1D1E26);
    const borderColor = Color(0xFF282936);
    const primaryYellow = Color(0xFFFFCC00);
    const textMuted = Color(0xFF9E9EA9);

    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: screenWidth * 0.85,
        height: double.infinity,
        color: drawerBackground,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------------
              // 1. Drawer Header (PolyAI PRO + Close Button)
              // ---------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryYellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.translate,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'PolyAI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF26200A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryYellow.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: primaryYellow,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22232D),
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -------------------------------------------------------
                      // 2. User Profile Card
                      // -------------------------------------------------------
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryYellow,
                                      width: 2,
                                    ),
                                  ),
                                  child: const CircleAvatar(
                                    backgroundColor: Color(0xFF2A2B36),
                                    child: Text(
                                      'A',
                                      style: TextStyle(
                                        color: primaryYellow,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: primaryYellow,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: cardColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Text(
                                        'Alex Chen',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.verified,
                                        color: primaryYellow,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'alex.chen@polyai.io',
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: primaryYellow,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Spring Boot Synced',
                                        style: TextStyle(
                                          color: primaryYellow,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: textMuted,
                              size: 22,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // -------------------------------------------------------
                      // 3. Navigation Header (NAVIGATION - 3 items)
                      // -------------------------------------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'NAVIGATION',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            '3 items',
                            style: TextStyle(color: textMuted, fontSize: 11),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Item 1: Profile
                      _DrawerTile(
                        icon: Icons.badge_outlined,
                        title: 'Profile',
                        subtitle: 'Personal details & credentials',
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/profile');
                        },
                      ),

                      const SizedBox(height: 10),

                      // Item 2: Settings
                      _DrawerTile(
                        icon: Icons.tune_outlined,
                        title: 'Settings',
                        subtitle: 'Audio engine, haptics & sync',
                        onTap: () {},
                      ),

                      const SizedBox(height: 10),

                      // Item 3: About App
                      _DrawerTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About App',
                        versionBadge: 'v1.0.4',
                        subtitle: 'PolyAI Architecture & Licenses',
                        onTap: () {},
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // 4. Footer Section (Sign Out & Sync Status)
              // ---------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: borderColor, height: 1),
                    const SizedBox(height: 16),

                    // Sign Out Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.read<AuthBloc>().add(
                          const AuthLogoutRequested(),
                        );
                      },
                      child: Row(
                        children: const [
                          Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFFF6B6B),
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Status Pill
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'PolyAI Mobile Suite',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Flutter 3.x · Spring 3.x',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF26200A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryYellow.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: primaryYellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Connected',
                                style: TextStyle(
                                  color: primaryYellow,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.versionBadge,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? versionBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF1D1E26);
    const borderColor = Color(0xFF282936);
    const primaryYellow = Color(0xFFFFCC00);
    const textMuted = Color(0xFF9E9EA9);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF26200A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryYellow.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, color: primaryYellow, size: 20),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (versionBadge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF26200A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: primaryYellow.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  versionBadge!,
                  style: const TextStyle(
                    color: primaryYellow,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: textMuted, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: textMuted,
          size: 20,
        ),
      ),
    );
  }
}
