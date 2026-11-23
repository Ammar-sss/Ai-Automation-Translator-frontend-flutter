import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/pill.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/speak_button.dart';

class PracticeCardFront extends StatelessWidget {
  final Term term;
  final bool isPlayingAudio;
  final VoidCallback onSpeakPressed;

  const PracticeCardFront({
    super.key,
    required this.term,
    required this.isPlayingAudio,
    required this.onSpeakPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final languageLabel =
        (term.targetLanguage != null && term.targetLanguage!.isNotEmpty)
        ? 'NOUN • ${term.targetLanguage!.toUpperCase()}'
        : 'NOUN • SLANG';
    final hasHint =
        term.sourceLanguage != null && term.sourceLanguage!.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 430;
        final avatarSize = compact ? 64.0 : 88.0;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Pill(
                          color: scheme.surfaceContainerHigh,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Text(
                            languageLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Pill(
                          color: scheme.primaryContainer.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          child: Text(
                            'B2 Master',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SpeakButton(
                    isLoading: isPlayingAudio,
                    onPressed: onSpeakPressed,
                  ),
                ],
              ),

              const Spacer(),

              Center(
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.35),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.12),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primaryContainer.withValues(alpha: 0.4),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.translate_rounded,
                        size: avatarSize * 0.45,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: compact ? 14 : 22),

              Text(
                term.termWord,
                textAlign: TextAlign.center,
                style: text.headlineLarge?.copyWith(
                  fontSize: compact ? 32 : 40,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Pill(
                  color: scheme.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '/${term.termWord.toLowerCase()}/',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (hasHint && !compact) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Informal, derogatory or slang term',
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 15,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap anywhere to flip definition',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
