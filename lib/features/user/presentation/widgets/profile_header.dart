import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final bool isEnabled;
  final VoidCallback onEdit;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    required this.isEnabled,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = isEnabled ? Colors.green : Colors.orange;

    return Column(
      children: [
        const SizedBox(height: 8),
        CircleAvatar(
          radius: 52,
          backgroundColor: scheme.primaryContainer,
          child: Text(
            username.isNotEmpty ? username[0].toUpperCase() : 'U',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w700,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isEnabled
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                isEnabled ? 'Active account' : 'Deactivated account',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.tonalIcon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit profile'),
        ),
      ],
    );
  }
}
