import 'package:material_ui/material_ui.dart';

import '../../../../core/util/responsive.dart';
import '../../../../core/util/translation_language.dart';
import 'language_dropdown.dart';

class LanguageBar extends StatelessWidget {
  final TranslationLanguage source;
  final TranslationLanguage target;
  final ValueChanged<TranslationLanguage?> onSourceChanged;
  final ValueChanged<TranslationLanguage?> onTargetChanged;
  final VoidCallback onSwap;

  const LanguageBar({
    super.key,
    required this.source,
    required this.target,
    required this.onSourceChanged,
    required this.onTargetChanged,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: LanguageDropdown(
            selectedValue: source,
            onChanged: onSourceChanged,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.wp(2)),
          child: IconButton.filledTonal(
            onPressed: onSwap,
            tooltip: 'Swap languages',
            iconSize: context.sp(22, min: 20, max: 26),
            style: IconButton.styleFrom(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            icon: const Icon(Icons.swap_horiz_rounded),
          ),
        ),
        Expanded(
          child: LanguageDropdown(
            selectedValue: target,
            onChanged: onTargetChanged,
          ),
        ),
      ],
    );
  }
}
