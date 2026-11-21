import 'package:material_ui/material_ui.dart';

import '../../../../core/util/responsive.dart';

class EmptyHint extends StatelessWidget {
  final ValueChanged<String>? onSelectPrompt;

  const EmptyHint({super.key, this.onSelectPrompt});

  static const List<String> _samplePrompts = [
    'Serendipity',
    'Resilience',
    'Grateful',
    'Perseverance',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.translate_rounded,
                size: context.sp(40, min: 36, max: 48),
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Instant AI Translation',
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter any word or phrase above to get translations,\ndefinitions, and natural example sentences.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (onSelectPrompt != null) ...[
              const SizedBox(height: 24),
              Text(
                'TRY TRANSLATING',
                style: text.labelSmall?.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final prompt in _samplePrompts)
                    ActionChip(
                      label: Text(prompt),
                      avatar: const Icon(Icons.north_west_rounded, size: 14),
                      labelStyle: text.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: scheme.surfaceContainerHigh,
                      side: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () => onSelectPrompt!(prompt),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
