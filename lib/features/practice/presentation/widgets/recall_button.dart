import 'package:material_ui/material_ui.dart';

class RecallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color iconColor;
  final Color backgroundColor;
  final bool isFeatured;
  final VoidCallback onTap;

  const RecallButton({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.iconColor,
    required this.backgroundColor,
    this.isFeatured = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final size = isFeatured ? 64.0 : 56.0;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isFeatured
                ? null
                : Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant
                        .withValues(alpha: 0.6),
                  ),
            boxShadow: isFeatured
                ? [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: backgroundColor,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: size,
                height: size,
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: isFeatured ? 28 : 24,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: text.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: isFeatured ? 13 : 12,
          ),
        ),
        Text(
          sublabel,
          style: text.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
