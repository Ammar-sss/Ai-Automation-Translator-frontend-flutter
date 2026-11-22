import 'package:material_ui/material_ui.dart';

import 'recall_button.dart';

class PracticeActionControls extends StatelessWidget {
  final VoidCallback onAgain;
  final VoidCallback onHard;
  final VoidCallback onGotIt;

  const PracticeActionControls({
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
            const SizedBox(width: 6),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RecallButton(
              icon: Icons.close_rounded,
              label: 'Again',
              sublabel: '<1min',
              iconColor: scheme.onErrorContainer,
              backgroundColor: scheme.errorContainer,
              onTap: onAgain,
            ),
            RecallButton(
              icon: Icons.access_time_rounded,
              label: 'Hard',
              sublabel: '10 min',
              iconColor: scheme.onSurfaceVariant,
              backgroundColor: scheme.surfaceContainerHigh,
              onTap: onHard,
            ),
            RecallButton(
              icon: Icons.check_rounded,
              label: 'Got It',
              sublabel: '3 days',
              iconColor: scheme.onPrimary,
              backgroundColor: scheme.primary,
              isFeatured: true,
              onTap: onGotIt,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 13,
                  color: scheme.onSurfaceVariant,
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
