import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/pill.dart';

class TrickyTermRow extends StatelessWidget {
  final Term term;

  const TrickyTermRow({super.key, required this.term});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final definition = term.termDefinitions.isNotEmpty
        ? term.termDefinitions.first.definition
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Text(
            '!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: scheme.error,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  term.termWord,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (definition != null)
                  Text(
                    definition,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Pill(
            color: scheme.errorContainer,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Mistake',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
