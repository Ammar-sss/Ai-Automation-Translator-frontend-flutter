import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/pill.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/speak_button.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/info_tile.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/directional_text.dart';
import 'package:smart_translator_test/features/practice/presentation/utils/practice_text_utils.dart';

class PracticeCardBack extends StatelessWidget {
  final Term term;
  final bool isPlayingAudio;
  final VoidCallback onSpeakPressed;

  const PracticeCardBack({
    super.key,
    required this.term,
    required this.isPlayingAudio,
    required this.onSpeakPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final definitions = term.termDefinitions.map((d) => d.definition).toList();
    final examples = term.termExamples.toList();
    final exampleDefs = term.exampleDefinitions.toList();

    final primaryDefinition = definitions.isNotEmpty ? definitions.first : null;
    final otherDefinitions = definitions.length > 1
        ? definitions.sublist(1)
        : <String>[];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Pill(
                      color: scheme.primaryContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'REVEALED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'NOUN • INFORMAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SpeakButton(isLoading: isPlayingAudio, onPressed: onSpeakPressed),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            term.termWord,
            style: text.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '/${term.termWord.toLowerCase()}/',
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoTile(
                    tag: 'PRIMARY MEANING',
                    tagColor: scheme.primary.withValues(alpha: 0.15),
                    tagTextColor: scheme.primary,
                    child: primaryDefinition != null
                        ? DirectionalText(
                            primaryDefinition,
                            style: text.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                              height: 1.4,
                            ),
                          )
                        : Text(
                            'No definition recorded',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                  ),

                  if (otherDefinitions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    InfoTile(
                      tag: 'OTHER MEANINGS',
                      tagColor: scheme.secondaryContainer,
                      tagTextColor: scheme.onSecondaryContainer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final d in otherDefinitions)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: DirectionalText(
                                d,
                                style: text.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  if (examples.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildExampleBox(
                      term: term,
                      sentence: examples.first.exampleSentence,
                      translation: exampleDefs.isNotEmpty
                          ? exampleDefs.first.exampleDefinition
                          : null,
                      scheme: scheme,
                      text: text,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.replay_rounded,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tap card to flip back',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleBox({
    required Term term,
    required String sentence,
    required String? translation,
    required ColorScheme scheme,
    required TextTheme text,
  }) {
    final baseStyle = text.bodyLarge?.copyWith(
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
      height: 1.4,
    );
    final highlightStyle = baseStyle?.copyWith(
      color: scheme.primary,
      fontWeight: FontWeight.w800,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                'EXAMPLE IN CONTEXT',
                style: text.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: baseStyle,
              children: [
                const TextSpan(text: '\u201C'),
                ...highlightTerm(
                  sentence,
                  term.termWord,
                  baseStyle,
                  highlightStyle,
                ),
                const TextSpan(text: '\u201D'),
              ],
            ),
            textDirection: isRtl(sentence)
                ? TextDirection.rtl
                : TextDirection.ltr,
          ),
          if (translation != null && translation.isNotEmpty) ...[
            const SizedBox(height: 10),
            DirectionalText(
              translation,
              style: text.bodySmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
