import 'package:material_ui/material_ui.dart';

class SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const SummaryMetric({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: text.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor ?? scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
