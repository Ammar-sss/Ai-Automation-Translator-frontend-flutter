import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/translation/presentation/pages/translate_page.dart';
import '../../features/vocabulary/presentation/pages/vocabulary_page.dart';
import '../../features/user/presentation/widgets/profile_drawer.dart';

class MainWrapperPage extends StatefulWidget {
  const MainWrapperPage({super.key});

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomePage(), // Home is now the Translation page!
    VocabularyPage(), // Vocab
    TranslatePage(), // Practice / Extra Translate view
  ];

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF11131D);
    const navBackgroundColor = Color(0xFF15151B);
    const primaryOrange = Color(0xFFFF5A2C);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: primaryOrange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withValues(alpha: 0.5),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 26),
          onPressed: () {
            setState(() {
              _index = 0; // Go to Translate Home
            });
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: navBackgroundColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 10,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isSelected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _NavItem(
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book_rounded,
                label: 'Vocab',
                isSelected: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
              const SizedBox(width: 48), // Space for central FAB
              _NavItem(
                icon: Icons.flag_outlined,
                activeIcon: Icons.flag_rounded,
                label: 'Practice',
                isSelected: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                isSelected: false,
                onTap: () {
                  ProfileDrawer.open(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF5A2C);
    const inactiveColor = Color(0xFFAB8981);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? primaryOrange : inactiveColor,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : inactiveColor,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
