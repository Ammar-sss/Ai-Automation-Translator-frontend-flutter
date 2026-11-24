import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/recall_button.dart';

class PracticeRatingControls extends StatelessWidget {
  final VoidCallback onAgain;
  final VoidCallback onHard;
  final VoidCallback onGotIt;

  const PracticeRatingControls({
    super.key,
    required this.onAgain,
    required this.onHard,
    required this.onGotIt,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Rate recall memory strength',
              style: text.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RecallButton(
              icon: Icons.close_rounded,
              label: 'Again',
              sublabel: '<1min',
              size: 64,
              iconColor: scheme.onErrorContainer,
              backgroundColor: scheme.errorContainer,
              onTap: onAgain,
            ),
            RecallButton(
              icon: Icons.access_time_rounded,
              label: 'Hard',
              sublabel: '10 min',
              size: 48,
              iconColor: scheme.onSurfaceVariant,
              backgroundColor: scheme.surfaceContainerHigh,
              labelColor: scheme.onSurfaceVariant,
              onTap: onHard,
            ),
            RecallButton(
              icon: Icons.check_rounded,
              label: 'Got It',
              sublabel: '3 days',
              size: 64,
              iconColor: scheme.onPrimary,
              backgroundColor: scheme.primary,
              labelColor: scheme.primary,
              sublabelColor: scheme.primary,
              glow: true,
              onTap: onGotIt,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: Colors.green,
                ),
                const SizedBox(width: 5),
                Text(
                  'Retention: 92%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.keyboard_outlined,
                  size: 13,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Text(
                  'Space to flip',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
