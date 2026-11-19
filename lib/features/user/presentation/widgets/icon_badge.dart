import 'package:flutter/material.dart';

class IconBadge extends StatelessWidget {
  final IconData icon;
  const IconBadge(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 22, color: scheme.onSecondaryContainer),
    );
  }
}