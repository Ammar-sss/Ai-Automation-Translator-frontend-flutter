import 'package:material_ui/material_ui.dart';

class VocabularyHeader extends StatelessWidget {
  final int? folderCount;
  final int? totalTermsCount;
  final VoidCallback onRefresh;

  const VocabularyHeader({
    super.key,
    required this.folderCount,
    required this.totalTermsCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vocabulary',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              if (folderCount != null && totalTermsCount != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    _StatBadge(
                      label:
                          '$folderCount ${folderCount == 1 ? 'folder' : 'folders'}',
                    ),
                    const SizedBox(width: 8),
                    _StatBadge(
                      label:
                          '$totalTermsCount ${totalTermsCount == 1 ? 'word' : 'words'}',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Refresh',
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;

  const _StatBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
