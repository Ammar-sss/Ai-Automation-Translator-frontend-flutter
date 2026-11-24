import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:dio/dio.dart';
import 'package:smart_translator_test/app_snackbar.dart';
import 'package:smart_translator_test/core/network/elevenlabs_service.dart';
import 'package:smart_translator_test/core/services/audio_player_service.dart';

import '../../../../core/util/responsive.dart';
import '../controller/translate_cubit.dart';

class ResultCard extends StatelessWidget {
  final TranslateLoaded state;
  final ValueNotifier<bool> isSaving;
  final VoidCallback onSave;
  final String targetLanguageCode;

  ResultCard({
    super.key,
    required this.state,
    required this.isSaving,
    required this.onSave,
    required this.targetLanguageCode,
  });

  final ElevenLabsService _elevenLabsService = ElevenLabsService(Dio());

  void _copyResult(BuildContext context) {
    final res = state.aiResponse;
    final buffer = StringBuffer();
    buffer.writeln(res.termWord);
    if (res.termDefinitions.isNotEmpty) {
      buffer.writeln('Meanings: ${res.termDefinitions.join(', ')}');
    }
    if (res.exampleSentence.isNotEmpty) {
      buffer.writeln('Example: ${res.exampleSentence}');
      if (res.exampleDefinition.isNotEmpty) {
        buffer.writeln('Translation: ${res.exampleDefinition}');
      }
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    showAppSnackBar(context, 'Translation copied to clipboard');
  }

  Future<void> _pronounceResult(BuildContext context) async {
    final res = state.aiResponse;
    showAppSnackBar(context, 'Synthesizing speech for "${res.termWord}"...');
    try {
      final audioBytes = await _elevenLabsService.textToSpeech(
        res.termWord,
        languageCode: targetLanguageCode,
      );
      if (!context.mounted) return;
      if (audioBytes != null) {
        await AudioPlayerService().playBytes(audioBytes);
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
    final res = state.aiResponse;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.wp(5)),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Translated Word Header & Copy Action
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    res.termWord,
                    style: text.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: scheme.onSurface,
                      height: 1.15,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => _pronounceResult(context),
                      tooltip: 'Pronounce translation',
                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () => _copyResult(context),
                      tooltip: 'Copy translation',
                      icon: const Icon(Icons.copy_rounded, size: 20),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: context.hp(2)),

            // Meanings / Definitions Section
            Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  'MEANINGS',
                  style: text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
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
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
              ],
            ),

            // Example Sentence & Translation Section
            if (res.exampleSentence.isNotEmpty) ...[
              SizedBox(height: context.hp(2.5)),
              Row(
                children: [
                  Icon(
                    Icons.subtitles_outlined,
                    size: 16,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'EXAMPLE SENTENCE',
                    style: text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.hp(1)),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(context.wp(4)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                res.exampleSentence,
                                style: text.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                  color: scheme.onSurface,
                                ),
                              ),
                              if (res.exampleDefinition.isNotEmpty) ...[
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
                                        res.exampleDefinition,
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
              ),
            ],

            SizedBox(height: context.hp(3)),

            // Save to Vocabulary Button
            ValueListenableBuilder<bool>(
              valueListenable: isSaving,
              builder: (context, saving, _) => FilledButton.icon(
                onPressed: saving ? null : onSave,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: saving
                    ? SizedBox(
                        height: context.sp(18),
                        width: context.sp(18),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bookmark_add_rounded),
                label: Text(
                  saving ? 'Saving to vocabulary…' : 'Save to vocabulary',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
