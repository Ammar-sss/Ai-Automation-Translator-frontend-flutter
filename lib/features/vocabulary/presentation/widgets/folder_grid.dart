import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';

import 'folder_card.dart';

/// Sliver list of folders: 1 column on phones, 2+ on wider screens.
/// Lives inside the page's CustomScrollView so the large title collapses
/// and pull-to-refresh works.
class FolderGrid extends StatelessWidget {
  final List<FolderInfo> folders;
  final ValueChanged<Folder> onTap;
  final ValueChanged<Folder> onRename;
  final ValueChanged<Folder> onDelete;

  const FolderGrid({
    super.key,
    required this.folders,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 420,
          mainAxisExtent: 72,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final info = folders[index];
          return FolderCard(
            key: ValueKey(info.folder.id),
            info: info,
            onTap: () => onTap(info.folder),
            onRename: () => onRename(info.folder),
            onDelete: () => onDelete(info.folder),
          );
        },
      ),
    );
  }
}
