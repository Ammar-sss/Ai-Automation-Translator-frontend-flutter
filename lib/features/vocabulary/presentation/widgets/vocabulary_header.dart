import 'package:material_ui/material_ui.dart';

/// Small summary line under the large "Vocabulary" title.
/// (The title itself is now a SliverAppBar.large in the page.)
class VocabularyHeader extends StatelessWidget {
  final int? folderCount;
  final int? totalTermsCount;

  const VocabularyHeader({
    super.key,
    required this.folderCount,
    required this.totalTermsCount,
  });

  @override
  Widget build(BuildContext context) {
    if (folderCount == null || totalTermsCount == null) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    final folders = '$folderCount ${folderCount == 1 ? 'folder' : 'folders'}';
    final words = '$totalTermsCount ${totalTermsCount == 1 ? 'word' : 'words'}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Text(
        '$folders · $words',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
