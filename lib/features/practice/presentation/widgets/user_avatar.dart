import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 16,
      backgroundColor: scheme.primaryContainer,
      child: Icon(
        Icons.person_rounded,
        size: 18,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}
