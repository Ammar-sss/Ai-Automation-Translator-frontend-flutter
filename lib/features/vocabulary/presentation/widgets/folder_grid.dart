import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';

import 'folder_card.dart';

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
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.25,
      ),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final info = folders[index];
        return FolderCard(
          info: info,
          onTap: () => onTap(info.folder),
          onRename: () => onRename(info.folder),
          onDelete: () => onDelete(info.folder),
        );
      },
    );
  }
}
