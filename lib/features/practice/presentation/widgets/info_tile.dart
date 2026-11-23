import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/pill.dart';

/// Rounded tile with a small tag pill on top (Primary meaning, etc.).
class InfoTile extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final Widget child;

  const InfoTile({
    super.key,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(
            color: tagColor,
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: tagTextColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
