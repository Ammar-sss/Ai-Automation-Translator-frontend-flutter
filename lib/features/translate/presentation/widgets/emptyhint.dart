import 'package:flutter/material.dart';

import '../../../../core/util/responsive.dart';

class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.translate_rounded,
            size: context.sp(44, min: 40, max: 56),
            color: scheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Translations and examples appear here',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
