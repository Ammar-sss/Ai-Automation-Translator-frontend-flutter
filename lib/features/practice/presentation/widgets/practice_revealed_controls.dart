import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/recall_button.dart';

class PracticeRevealedControls extends StatelessWidget {
  final VoidCallback onAgain;
  final VoidCallback onGotIt;

  const PracticeRevealedControls({
    super.key,
    required this.onAgain,
    required this.onGotIt,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecallButton(
            icon: Icons.close_rounded,
            label: 'AGAIN',
            size: 64,
            iconColor: scheme.onErrorContainer,
            backgroundColor: scheme.errorContainer,
            onTap: onAgain,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Container(
                        width: 5,
                        height: 5,
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: i == 0
                              ? scheme.primary
                              : scheme.outlineVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Level 1',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          RecallButton(
            icon: Icons.check_rounded,
            label: 'GOT IT',
            size: 64,
            iconColor: scheme.onPrimary,
            backgroundColor: scheme.primary,
            labelColor: scheme.primary,
            glow: true,
            onTap: onGotIt,
          ),
        ],
      ),
    );
  }
}
