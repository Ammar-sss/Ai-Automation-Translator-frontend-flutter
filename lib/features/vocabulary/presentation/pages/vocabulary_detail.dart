import 'package:flutter/material.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';

class VocabularyDetail extends StatelessWidget {
  final Term term;
  const VocabularyDetail({super.key, required this.term});

  /// Opens the detail as a themed bottom sheet.
  static Future<void> show(BuildContext context, Term term) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => VocabularyDetail(term: term),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Term headline + close
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    term.termWord,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Definitions
            _SectionTitle('Definitions', color: scheme.onSurfaceVariant),
            const SizedBox(height: 10),
            if (term.termDefinitions.isEmpty)
              Text(
                'No definitions available.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final def in term.termDefinitions)
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
                        def.definition,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                ],
              ),

            // Examples
            if (term.termExamples.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionTitle('Examples', color: scheme.onSurfaceVariant),
              const SizedBox(height: 10),
              for (final ex in term.termExamples)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(color: scheme.primary, width: 3),
                    ),
                  ),
                  child: Text(
                    ex.exampleSentence,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionTitle(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
    );
  }
}