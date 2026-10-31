import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator/core/router/route_name.dart';
import 'package:smart_translator/features/auth/presentation/controllers/auth_bloc.dart';
import 'package:smart_translator/features/user/presentation/controllers/user_cubit.dart';
import 'package:smart_translator/features/user/presentation/widgets/profile_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF11131D);
    const containerColor = Color(0xFF1E1F2A);
    const cardBorderColor = Color(0xFF282935);
    const primaryOrange = Color(0xFFFF5A2C);
    const successGreen = Color(0xFF4AE183);
    const pendingGold = Color(0xFFFFB020);
    const textMuted = Color(0xFFAB8981);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: successGreen.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: successGreen,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Online',
                    style: TextStyle(
                      color: successGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white70,
              size: 22,
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => ProfileDrawer.open(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB5A1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF601300),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            final userName =
                (state is UserLoaded &&
                    state.user.username != null &&
                    state.user.username!.isNotEmpty)
                ? state.user.username!
                : 'Linh Nguyen';
            final userEmail =
                (state is UserLoaded &&
                    state.user.email != null &&
                    state.user.email!.isNotEmpty)
                ? state.user.email!
                : 'linh.nguyen@example.com';
            final userInitial = userName.isNotEmpty
                ? userName[0].toUpperCase()
                : 'L';

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // User Avatar & Hero Section
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: primaryOrange,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryOrange.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: 28,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  userInitial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push(RouteName.editProfile),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF282935),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: backgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified_rounded,
                              color: successGreen,
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Badges Row (Online & Synced, Pro Learner, Active)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2A22),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: successGreen.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
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
                                    'Online & Synced',
                                    style: TextStyle(
                                      color: successGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF332A18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: pendingGold.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.bolt_rounded,
                                    color: pendingGold,
                                    size: 13,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Pro Learner',
                                    style: TextStyle(
                                      color: pendingGold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2A22),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: successGreen.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.check_rounded,
                                    color: successGreen,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      color: successGreen,
                                      fontSize: 10,
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
                  const SizedBox(height: 24),

                  // 2-Column Metric Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Column(
                            children: const [
                              Text(
                                '142',
                                style: TextStyle(
                                  color: primaryOrange,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'TERMS',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Column(
                            children: const [
                              Text(
                                '139',
                                style: TextStyle(
                                  color: primaryOrange,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'SYNCED',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Card Group 1 (Edit Profile & Account Status)
                  Container(
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: Column(
                      children: [
                        _ProfileOptionTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit profile',
                          onTap: () => context.push(RouteName.editProfile),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(color: cardBorderColor, height: 1),
                        ),
                        _ProfileOptionTile(
                          icon: Icons.verified_user_rounded,
                          iconColor: successGreen,
                          title: 'Account status',
                          subtitle: 'Verified & active',
                          badge: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2A22),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: successGreen.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: successGreen,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Active',
                                  style: TextStyle(
                                    color: successGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {},
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(color: cardBorderColor, height: 1),
                        ),
                        _ProfileOptionTile(
                          icon: Icons.sync_rounded,
                          iconColor: successGreen,
                          title: 'Sync status',
                          badge: const Text(
                            '✓ 139/142',
                            style: TextStyle(
                              color: successGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card Group 2 (Reminders & Offline)
                  Container(
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: Column(
                      children: [
                        _ProfileOptionTile(
                          icon: Icons.notifications_none_rounded,
                          iconColor: const Color(0xFFFFB020),
                          title: 'Practice reminders',
                          onTap: () {},
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(color: cardBorderColor, height: 1),
                        ),
                        _ProfileOptionTile(
                          icon: Icons.download_for_offline_outlined,
                          title: 'Offline dictionary packs',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card Group 3 (Log Out)
                  Container(
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: _ProfileOptionTile(
                      icon: Icons.logout_rounded,
                      iconColor: Colors.redAccent,
                      title: 'Log out',
                      titleColor: Colors.redAccent,
                      onTap: () {
                        context.read<AuthBloc>().add(
                          const AuthLogoutRequested(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer Version Info
                  const Text(
                    'AI Translator v2.4.1 (Build 890)',
                    style: TextStyle(color: textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  const _ProfileOptionTile({
    required this.icon,
    this.iconColor = Colors.white70,
    required this.title,
    this.subtitle,
    this.titleColor = Colors.white,
    this.badge,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color titleColor;
  final Widget? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const textMuted = Color(0xFFAB8981);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF282935),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(color: textMuted, fontSize: 11),
                    ),
                  ],
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
