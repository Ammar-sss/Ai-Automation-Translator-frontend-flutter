import 'package:material_ui/material_ui.dart';

/// Tilted card stack with a skeleton and progress bar, plus a soft glow.
class EmptyDeckIllustration extends StatelessWidget {
  final int saved;
  final int needed;

  const EmptyDeckIllustration({
    super.key,
    required this.saved,
    required this.needed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Transform.rotate(
            angle: -0.09,
            child: Container(
              width: 168,
              height: 112,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
          Container(
            width: 172,
            height: 116,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.style_rounded, size: 20, color: scheme.primary),
                    Text(
                      '$saved / $needed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  width: 88,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: saved / needed,
                    minHeight: 6,
                    backgroundColor: scheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 34,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: scheme.primary,
            ),
          ),
          const Positioned(
            bottom: 36,
            left: 38,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 11,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}
