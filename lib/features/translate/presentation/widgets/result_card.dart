import 'package:flutter/material.dart';

import '../../../../core/util/responsive.dart';
import '../controller/translate_cubit.dart';

class ResultCard extends StatelessWidget {
  final TranslateLoaded state;
  final ValueNotifier<bool> isSaving;
  final VoidCallback onSave;

  const ResultCard({
    super.key,
    required this.state,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final res = state.aiResponse;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.wp(5)),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(context.defaultRadius * 2),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline: the translated term
            Text(
              res.termWord,
              style: TextStyle(
                fontSize: context.sp(28, min: 24, max: 34),
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: scheme.onSurface,
              ),
            ),
            SizedBox(height: context.hp(2)),

            // Meanings
            Text(
              'Meanings',
              style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            SizedBox(height: context.hp(1)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final def in res.termDefinitions)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      def,
                      style: TextStyle(
                        fontSize: context.sp(15, min: 14, max: 16),
                        fontWeight: FontWeight.w500,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
              ],
            ),

            // Example
            if (res.exampleSentence.isNotEmpty) ...[
              SizedBox(height: context.hp(2.5)),
              Text(
                'Example',
                style: text.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: context.hp(1)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.wp(4)),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(context.defaultRadius),
                  border: Border(
                    left: BorderSide(color: scheme.primary, width: 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      res.exampleSentence,
                      style: TextStyle(
                        fontSize: context.sp(16, min: 14, max: 18),
                        height: 1.4,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (res.exampleDefinition.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        res.exampleDefinition,
                        style: TextStyle(
                          fontSize: context.sp(14, min: 13, max: 15),
                          height: 1.4,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            SizedBox(height: context.hp(3)),

            // Save: only this button rebuilds while saving.
            ValueListenableBuilder<bool>(
              valueListenable: isSaving,
              builder: (context, saving, _) => FilledButton.tonalIcon(
                onPressed: saving ? null : onSave,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      context.defaultRadius * 1.5,
                    ),
                  ),
                ),
                icon: saving
                    ? SizedBox(
                        height: context.sp(18),
                        width: context.sp(18),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bookmark_add_outlined),
                label: Text(saving ? 'Saving…' : 'Save to vocabulary'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
