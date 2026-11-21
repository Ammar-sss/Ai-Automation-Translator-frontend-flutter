import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';

/// Modal bottom sheet allowing the user to select which folder to save a term into.
class FolderPickerSheet extends StatefulWidget {
  final String termWord;

  const FolderPickerSheet({super.key, required this.termWord});

  /// Displays the picker and returns the selected [Folder], or null if dismissed.
  static Future<Folder?> show(
    BuildContext context, {
    required String termWord,
  }) {
    return showModalBottomSheet<Folder>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => FolderPickerSheet(termWord: termWord),
    );
  }

  @override
  State<FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends State<FolderPickerSheet> {
  final Set<int> _alreadyContainingFolderIds = {};

  @override
  void initState() {
    super.initState();
    // Refresh folder list to get updated term counts
    context.read<FolderCubit>().loadFolders();
    _checkExistingLinks();
  }

  Future<void> _checkExistingLinks() async {
    try {
      final ids = await AppDatabase.instance.getFolderIdsForTerm(
        widget.termWord,
      );
      if (mounted) {
        setState(() {
          _alreadyContainingFolderIds.addAll(ids);
        });
      }
    } catch (_) {}
  }

  Future<void> _showCreateFolderDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Folder name',
            prefixIcon: const Icon(Icons.folder_open_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onSubmitted: (val) => Navigator.pop(ctx, val),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name != null && name.trim().isNotEmpty && mounted) {
      final trimmed = name.trim();
      final newId = await AppDatabase.instance.createFolder(trimmed);
      if (!mounted) return;
      context.read<FolderCubit>().loadFolders();
      final all = await AppDatabase.instance.getAllFolders();
      final created = all.firstWhere(
        (f) => f.name.toLowerCase() == trimmed.toLowerCase() || f.id == newId,
      );
      if (mounted) {
        Navigator.pop(context, created);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                      const Text(
                        'Save to Folder',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Where would you like to save "${widget.termWord}"?',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'New Folder',
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _showCreateFolderDialog,
                  icon: const Icon(Icons.create_new_folder_outlined),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: BlocBuilder<FolderCubit, FolderState>(
                builder: (context, state) {
                  final folders = switch (state) {
                    FoldersLoaded(folders: final f) => f,
                    _ => const <FolderInfo>[],
                  };

                  if (folders.isEmpty) {
                    if (state is FolderLoading || state is FolderInitial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.folder_open_rounded,
                                size: 40,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No folders yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Create a folder to store this word.',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 14),
                            FilledButton.tonalIcon(
                              onPressed: _showCreateFolderDialog,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Create folder'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: folders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = folders[index];
                      final isAlreadyIn = _alreadyContainingFolderIds.contains(
                        item.folder.id,
                      );

                      return Material(
                        color: isAlreadyIn
                            ? scheme.surfaceContainerHighest.withValues(
                                alpha: 0.4,
                              )
                            : scheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isAlreadyIn
                                ? scheme.primary.withValues(alpha: 0.3)
                                : scheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isAlreadyIn
                                  ? scheme.primaryContainer.withValues(
                                      alpha: 0.6,
                                    )
                                  : scheme.secondaryContainer.withValues(
                                      alpha: 0.5,
                                    ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isAlreadyIn
                                  ? Icons.folder_special_rounded
                                  : Icons.folder_rounded,
                              color: isAlreadyIn
                                  ? scheme.primary
                                  : scheme.secondary,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            item.folder.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            isAlreadyIn
                                ? 'Already saved in this folder'
                                : (item.termCount == 1
                                      ? '1 term'
                                      : '${item.termCount} terms'),
                            style: TextStyle(
                              color: isAlreadyIn
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          trailing: isAlreadyIn
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: scheme.primary,
                                  size: 22,
                                )
                              : const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.pop(context, item.folder);
                          },
                        ),
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
