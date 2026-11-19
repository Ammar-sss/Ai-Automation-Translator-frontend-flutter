import 'package:material_ui/material_ui.dart';

import '../../../../core/util/responsive.dart';
import '../../../../core/util/translation_language.dart';

/// Pill-shaped language picker. Each side of the language bar gets its own
/// pill so source/target read as two clear choices.
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

  // Built once, not on every rebuild.
  static final List<TranslationLanguage> _languages =
      TranslationLanguage.values;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.wp(3.5)),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(context.defaultRadius * 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TranslationLanguage>(
          value: selectedValue,
          isExpanded: true,
          dropdownColor: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(context.defaultRadius),
          icon: Icon(
            Icons.expand_more_rounded,
            size: context.sp(22, min: 20, max: 26),
            color: scheme.onSurfaceVariant,
          ),
          style: TextStyle(
            fontSize: context.sp(15, min: 14, max: 17),
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
          items: [
            for (final lang in _languages)
              DropdownMenuItem<TranslationLanguage>(
                value: lang,
                child: Text(_label(lang), overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
