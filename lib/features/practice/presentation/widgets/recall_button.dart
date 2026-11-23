import 'package:material_ui/material_ui.dart';

class RecallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final double size;
  final Color iconColor;
  final Color backgroundColor;
  final Color? labelColor;
  final Color? sublabelColor;
  final bool glow;
  final VoidCallback onTap;

  const RecallButton({
    super.key,
    required this.icon,
    required this.label,
    this.sublabel,
    required this.size,
    required this.iconColor,
    required this.backgroundColor,
    this.labelColor,
    this.sublabelColor,
    this.glow = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.42),
                      blurRadius: 22,
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
                  child: Icon(icon, color: iconColor, size: size * 0.42),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: text.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: size < 56 ? 12 : 13,
            color: labelColor ?? scheme.onSurface,
          ),
        ),
        if (sublabel != null)
          Text(
            sublabel!,
            style: text.labelSmall?.copyWith(
              color: sublabelColor ?? scheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
