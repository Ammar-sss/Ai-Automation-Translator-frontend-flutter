import 'package:material_ui/material_ui.dart';

import '../../../../core/util/responsive.dart';
import '../../../../core/util/translation_language.dart';

/// Pill-shaped language picker for source and target language selection.
class LanguageDropdown extends StatelessWidget {
  final TranslationLanguage selectedValue;
  final ValueChanged<TranslationLanguage?> onChanged;

  const LanguageDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  static String _label(TranslationLanguage lang) =>
      lang.name[0].toUpperCase() + lang.name.substring(1);

  static final List<TranslationLanguage> _languages =
      TranslationLanguage.values;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: context.wp(3.5)),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TranslationLanguage>(
          value: selectedValue,
          isExpanded: true,
          dropdownColor: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          icon: Icon(
            Icons.unfold_more_rounded,
            size: context.sp(20, min: 18, max: 24),
            color: scheme.primary,
          ),
          style: TextStyle(
            fontSize: context.sp(15, min: 14, max: 17),
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
          items: [
            for (final lang in _languages)
              DropdownMenuItem<TranslationLanguage>(
                value: lang,
                child: Row(
                  children: [
                    Text(
                      _label(lang),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: lang == selectedValue
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: lang == selectedValue
                            ? scheme.primary
                            : scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
