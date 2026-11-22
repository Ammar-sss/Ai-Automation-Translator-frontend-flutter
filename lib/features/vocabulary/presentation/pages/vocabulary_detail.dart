import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:smart_translator_test/app_snackbar.dart';
import 'package:smart_translator_test/core/network/elevenlabs_service.dart';
import 'package:smart_translator_test/core/util/language_detect.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';

class VocabularyDetail extends StatelessWidget {
  final Term term;
  VocabularyDetail({super.key, required this.term});

  final ElevenLabsService _elevenLabsService = ElevenLabsService(Dio());
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Opens the detail as a bottom sheet.
  static Future<void> show(BuildContext context, Term term) {
    final scheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => VocabularyDetail(term: term),
    );
  }

  void _copyWord(BuildContext context) {
    Clipboard.setData(ClipboardData(text: term.termWord));
    showAppSnackBar(context, '"${term.termWord}" copied to clipboard');
  }

  Future<void> _speak(BuildContext context, String text) async {
    showAppSnackBar(context, 'Synthesizing speech...');
    try {
      final audioBytes = await _elevenLabsService.textToSpeech(
        text,
        languageCode: detectLanguageCode(text),
      );
      if (!context.mounted) return;
      if (audioBytes != null) {
        await _audioPlayer.stop();
        await _audioPlayer.play(BytesSource(audioBytes));
      } else {
        showAppSnackBar(context, 'Failed to generate speech.');
      }
    } catch (e) {
      if (!context.mounted) return;
      showAppSnackBar(context, 'Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final definitions = term.termDefinitions.toList(growable: false);
    final examples = term.termExamples.toList(growable: false);
    final translations = term.exampleDefinitions.toList(growable: false);
    final paired = translations.length == examples.length;

    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Header with Word & Action Buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      term.termWord,
                      style: text.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => _speak(context, term.termWord),
                        tooltip: 'Pronounce word',
                        icon: const Icon(Icons.volume_up_rounded, size: 20),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => _copyWord(context),
                        tooltip: 'Copy word',
                        icon: const Icon(Icons.copy_rounded, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Summary Stats Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatBadge(
                    icon: Icons.book_outlined,
                    label:
                        '${definitions.length} ${definitions.length == 1 ? 'definition' : 'definitions'}',
                  ),
                  if (examples.isNotEmpty)
                    _StatBadge(
                      icon: Icons.format_quote_rounded,
                      label:
                          '${examples.length} ${examples.length == 1 ? 'example' : 'examples'}',
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Definitions Section
              _SectionHeader(
                icon: Icons.menu_book_rounded,
                title: 'Definitions',
              ),
              const SizedBox(height: 12),
              if (definitions.isEmpty)
                _EmptyCard(
                  icon: Icons.book_outlined,
                  message: 'No definitions available for this word.',
                )
              else
                for (final (i, def) in definitions.indexed)
                  _DefinitionCard(
                    index: i + 1,
                    definition: def.definition,
                    onPronounce: () => _speak(context, def.definition),
                  ),

              const SizedBox(height: 24),

              // Examples Section
              _SectionHeader(icon: Icons.subtitles_outlined, title: 'Examples'),
              const SizedBox(height: 12),
              if (examples.isEmpty)
                _EmptyCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  message: 'No example sentences added yet.',
                )
              else ...[
                for (final (i, ex) in examples.indexed)
                  _ExampleCard(
                    sentence: ex.exampleSentence,
                    translation: paired
                        ? translations[i].exampleDefinition
                        : null,
                  ),
                if (!paired && translations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  for (final t in translations)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.translate_rounded,
                            size: 16,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.exampleDefinition,
                              style: text.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: text.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DefinitionCard extends StatelessWidget {
  final int index;
  final String definition;
  final VoidCallback? onPronounce;

  const _DefinitionCard({
    required this.index,
    required this.definition,
    this.onPronounce,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: text.labelMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                definition,
                style: text.bodyLarge?.copyWith(
                  height: 1.4,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
          if (onPronounce != null)
            IconButton(
              icon: Icon(
                Icons.volume_up_rounded,
                size: 20,
                color: scheme.primary,
              ),
              onPressed: onPronounce,
            ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String sentence;
  final String? translation;

  const _ExampleCard({required this.sentence, this.translation});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Decorative left accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sentence,
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    if (translation != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.subdirectory_arrow_right_rounded,
                            size: 16,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              translation!,
                              style: text.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
