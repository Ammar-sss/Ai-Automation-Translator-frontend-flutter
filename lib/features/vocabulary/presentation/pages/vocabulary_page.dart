import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/pages/folder_terms_page.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  Future<void> _showCreateFolderDialog(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          const _FolderInputDialog(title: 'New Folder', actionLabel: 'Create'),
    );

    if (name != null && name.trim().isNotEmpty && context.mounted) {
      context.read<FolderCubit>().createFolder(name.trim());
    }
  }

  Future<void> _showRenameFolderDialog(
    BuildContext context,
    Folder folder,
  ) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _FolderInputDialog(
        title: 'Rename Folder',
        initialValue: folder.name,
        actionLabel: 'Rename',
      ),
    );

    if (newName != null && newName.trim().isNotEmpty && context.mounted) {
      context.read<FolderCubit>().renameFolder(folder.id, newName.trim());
    }
  }

  Future<void> _confirmDeleteFolder(BuildContext context, Folder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Folder?'),
        content: Text(
          'Are you sure you want to delete "${folder.name}"?\n\n'
          'Terms will not be deleted if they belong to other folders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<FolderCubit>().deleteFolder(folder.id);
    }
  }

  void _openFolder(BuildContext context, Folder folder) {
    context.read<FolderCubit>().loadTermsInFolder(folder.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FolderTermsPage(folder: folder)),
    ).then((_) {
      if (context.mounted) {
        context.read<FolderCubit>().loadFolders();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<FolderCubit, FolderState>(
          listenWhen: (_, current) => current is FolderFailure,
          listener: (context, state) {
            if (state is FolderFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      state.message,
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                    backgroundColor: scheme.errorContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
            }
          },
          buildWhen: (_, current) =>
              current is FolderLoading ||
              current is FoldersLoaded ||
              current is FolderFailure ||
              current is FolderInitial,
          builder: (context, state) {
            final folders = state is FoldersLoaded ? state.folders : null;
            final folderCount = folders?.length;
            final totalTermsCount = folders?.fold<int>(
              0,
              (sum, item) => sum + item.termCount,
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    folderCount: folderCount,
                    totalTermsCount: totalTermsCount,
                    onRefresh: () => context.read<FolderCubit>().loadFolders(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: switch (state) {
                        FolderLoading() => const Center(
                          key: ValueKey('loading'),
                          child: CircularProgressIndicator(),
                        ),
                        FoldersLoaded(folders: final folders) =>
                          folders.isEmpty
                              ? _EmptyMessage(
                                  key: const ValueKey('empty'),
                                  icon: Icons.folder_outlined,
                                  title: 'No folders yet',
                                  subtitle: 'Create a folder to organize your vocabulary.',
                                  actionLabel: 'Create folder',
                                  onAction: () =>
                                      _showCreateFolderDialog(context),
                                )
                              : _FolderGrid(
                                  key: const ValueKey('grid'),
                                  folders: folders,
                                  onTap: (f) => _openFolder(context, f),
                                  onRename: (f) =>
                                      _showRenameFolderDialog(context, f),
                                  onDelete: (f) =>
                                      _confirmDeleteFolder(context, f),
                                ),
                        FolderFailure(message: final message) => _EmptyMessage(
                          key: const ValueKey('error'),
                          icon: Icons.error_outline_rounded,
                          title: 'Something went wrong',
                          subtitle: message,
                          actionLabel: 'Try again',
                          onAction: () =>
                              context.read<FolderCubit>().loadFolders(),
                        ),
                        _ => _EmptyMessage(
                          key: const ValueKey('initial'),
                          icon: Icons.folder_outlined,
                          title: 'Your vocabulary folders',
                          subtitle: 'Create folders to organize your words.',
                          actionLabel: 'Load folders',
                          onAction: () =>
                              context.read<FolderCubit>().loadFolders(),
                        ),
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateFolderDialog(context),
        tooltip: 'New folder',
        child: const Icon(Icons.create_new_folder_outlined),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Folder Input Dialog (Stateful to safely manage controller lifecycle)
// ---------------------------------------------------------------------------

class _FolderInputDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final String actionLabel;

  const _FolderInputDialog({
    required this.title,
    this.initialValue,
    required this.actionLabel,
  });

  @override
  State<_FolderInputDialog> createState() => _FolderInputDialogState();
}

class _FolderInputDialogState extends State<_FolderInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.pop(context, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          hintText: 'Folder name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.actionLabel)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final int? folderCount;
  final int? totalTermsCount;
  final VoidCallback onRefresh;

  const _Header({
    required this.folderCount,
    required this.totalTermsCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    String subtitle = '';
    if (folderCount != null) {
      final fText = folderCount == 1 ? '1 folder' : '$folderCount folders';
      final tText = totalTermsCount == 1 ? '1 word' : '$totalTermsCount words';
      subtitle = '$fText • $tText';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vocabulary',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Folder Grid
// ---------------------------------------------------------------------------

class _FolderGrid extends StatelessWidget {
  final List<FolderInfo> folders;
  final ValueChanged<Folder> onTap;
  final ValueChanged<Folder> onRename;
  final ValueChanged<Folder> onDelete;

  const _FolderGrid({
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
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final info = folders[index];
        return _FolderCard(
          info: info,
          onTap: () => onTap(info.folder),
          onRename: () => onRename(info.folder),
          onDelete: () => onDelete(info.folder),
        );
      },
    );
  }
}

class _FolderCard extends StatelessWidget {
  final FolderInfo info;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _FolderCard({
    required this.info,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant),
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
                  Icon(Icons.folder_rounded, color: scheme.primary, size: 32),
                  const Spacer(),
                  _PopupMenu(onRename: onRename, onDelete: onDelete),
                ],
              ),
              const Spacer(),
              Text(
                info.folder.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                info.termCount == 1 ? '1 term' : '${info.termCount} terms',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
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
                color: Theme.of(ctx).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupMenu extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _PopupMenu({required this.onRename, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      onSelected: (value) {
        switch (value) {
          case 'rename':
            onRename();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty / Error / Initial state
// ---------------------------------------------------------------------------

class _EmptyMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.3),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
