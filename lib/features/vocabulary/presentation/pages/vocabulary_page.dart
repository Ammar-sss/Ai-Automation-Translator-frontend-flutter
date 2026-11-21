import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/pages/folder_terms_page.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/empty_message.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/folder_grid.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/folder_input_dialog.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/vocabulary_header.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  Future<void> _showCreateFolderDialog(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          const FolderInputDialog(title: 'New Folder', actionLabel: 'Create'),
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
      builder: (_) => FolderInputDialog(
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
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isTablet ? 850 : double.infinity,
            ),
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
                      VocabularyHeader(
                        folderCount: folderCount,
                        totalTermsCount: totalTermsCount,
                        onRefresh: () =>
                            context.read<FolderCubit>().loadFolders(),
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
                                  ? EmptyMessage(
                                      key: const ValueKey('empty'),
                                      icon: Icons.folder_outlined,
                                      title: 'No folders yet',
                                      subtitle: 'Create a folder to organize your vocabulary.',
                                      actionLabel: 'Create folder',
                                      onAction: () =>
                                          _showCreateFolderDialog(context),
                                    )
                                  : FolderGrid(
                                      key: const ValueKey('grid'),
                                      folders: folders,
                                      onTap: (f) => _openFolder(context, f),
                                      onRename: (f) =>
                                          _showRenameFolderDialog(context, f),
                                      onDelete: (f) =>
                                          _confirmDeleteFolder(context, f),
                                    ),
                            FolderFailure(message: final message) =>
                              EmptyMessage(
                                key: const ValueKey('error'),
                                icon: Icons.error_outline_rounded,
                                title: 'Something went wrong',
                                subtitle: message,
                                actionLabel: 'Try again',
                                onAction: () =>
                                    context.read<FolderCubit>().loadFolders(),
                              ),
                            _ => EmptyMessage(
                              key: const ValueKey('initial'),
                              icon: Icons.folder_outlined,
                              title: 'Your vocabulary folders',
                              subtitle:
                                  'Create folders to organize your words.',
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
