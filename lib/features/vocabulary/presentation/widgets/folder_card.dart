import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';

import 'folder_popup_menu.dart';

class FolderCard extends StatelessWidget {
  final FolderInfo info;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const FolderCard({
    super.key,
    required this.info,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(20);

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.folder_rounded,
                      color: scheme.primary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  FolderPopupMenu(onRename: onRename, onDelete: onDelete),
                ],
              ),
              const Spacer(),
              Text(
                info.folder.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  info.termCount == 1 ? '1 term' : '${info.termCount} terms',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(ctx);
                  onRename();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: scheme.error,
                ),
                title: Text('Delete', style: TextStyle(color: scheme.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
