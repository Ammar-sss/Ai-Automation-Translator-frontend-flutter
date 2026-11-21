import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/empty_message.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/folder_input_dialog.dart';

/// Bottom sheet to choose which folder a term is saved into.
class FolderPickerSheet extends StatefulWidget {
  final String termWord;

  const FolderPickerSheet({super.key, required this.termWord});

  /// Returns the selected [Folder], or null if dismissed.
  static Future<Folder?> show(
    BuildContext context, {
    required String termWord,
  }) {
    return showModalBottomSheet<Folder>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => FolderPickerSheet(termWord: termWord),
    );
  }

  @override
  State<FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends State<FolderPickerSheet> {
  Set<int> _containing = const {};

  @override
  void initState() {
    super.initState();
    context.read<FolderCubit>().loadFolders();
    _checkExistingLinks();
  }

  Future<void> _checkExistingLinks() async {
    try {
      final ids = await AppDatabase.instance.getFolderIdsForTerm(
        widget.termWord,
      );
      if (mounted) setState(() => _containing = ids.toSet());
    } catch (_) {}
  }

  Future<void> _createFolder() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          const FolderInputDialog(title: 'New folder', actionLabel: 'Create'),
    );
    if (name == null || !mounted) return;

    final newId = await AppDatabase.instance.createFolder(name);
    final all = await AppDatabase.instance.getAllFolders();
    final created = all.firstWhere(
      (f) => f.id == newId || f.name.toLowerCase() == name.toLowerCase(),
    );
    if (!mounted) return;
    context.read<FolderCubit>().loadFolders();
    Navigator.pop(context, created);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Save to folder',
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '"${widget.termWord}"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'New folder',
                  onPressed: _createFolder,
                  icon: const Icon(Icons.create_new_folder_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: BlocBuilder<FolderCubit, FolderState>(
                builder: (context, state) {
                  final folders = state is FoldersLoaded
                      ? state.folders
                      : const <FolderInfo>[];

                  if (folders.isEmpty) {
                    if (state is FolderLoading || state is FolderInitial) {
                      return const SizedBox(
                        height: 160,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return SizedBox(
                      height: 260,
                      child: EmptyMessage(
                        icon: Icons.folder_open_rounded,
                        title: 'No folders yet',
                        subtitle: 'Create a folder to store this word.',
                        actionLabel: 'Create folder',
                        onAction: _createFolder,
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final item = folders[index];
                      final saved = _containing.contains(item.folder.id);

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Icon(
                          Icons.folder_rounded,
                          color: saved
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                        title: Text(item.folder.name),
                        subtitle: Text(
                          saved
                              ? 'Already saved here'
                              : (item.termCount == 1
                                    ? '1 term'
                                    : '${item.termCount} terms'),
                        ),
                        trailing: saved
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: scheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, item.folder),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
