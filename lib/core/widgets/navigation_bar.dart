import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../route/app_routes.dart';

class AppNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AppNavigationBar({super.key, required this.currentIndex});

  static final _routes = [
    AppRoutes.home,
    AppRoutes.translate,
    AppRoutes.vocabulary,
    AppRoutes.profile,
  ];

  static const _destinations = [
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
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: _destinations,
    );
  }
}
