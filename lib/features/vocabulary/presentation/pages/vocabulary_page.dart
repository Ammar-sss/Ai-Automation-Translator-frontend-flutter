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

  Future<void> _showCreateFolderDialog(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          const FolderInputDialog(title: 'New folder', actionLabel: 'Create'),
    );
    if (name != null && context.mounted) {
      context.read<FolderCubit>().createFolder(name);
    }
  }

  Future<void> _showRenameFolderDialog(
    BuildContext context,
    Folder folder,
  ) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => FolderInputDialog(
        title: 'Rename folder',
        initialValue: folder.name,
        actionLabel: 'Rename',
      ),
    );
    if (newName != null && context.mounted) {
      context.read<FolderCubit>().renameFolder(folder.id, newName);
    }
  }

  Future<void> _confirmDeleteFolder(BuildContext context, Folder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete folder?'),
        content: Text(
          '"${folder.name}" will be deleted. Terms that also belong to '
          'other folders are kept.',
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
    // FolderTermsPage loads its own terms in initState.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FolderTermsPage(folder: folder)),
    ).then((_) {
      if (context.mounted) context.read<FolderCubit>().loadFolders();
    });
  }

  /// Completes when the reload finishes so the pull-to-refresh spinner
  /// stays visible for the right amount of time.
  Future<void> _refresh(BuildContext context) async {
    final cubit = context.read<FolderCubit>();
    final done = cubit.stream.firstWhere(
      (s) => s is FoldersLoaded || s is FolderFailure,
    );
    cubit.loadFolders();
    await done.timeout(
      const Duration(seconds: 5),
      onTimeout: () => cubit.state,
    );
  }

  List<Widget> _slivers(BuildContext context, FolderState state) {
    return switch (state) {
      FoldersLoaded(folders: final folders) when folders.isEmpty => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyMessage(
            icon: Icons.folder_outlined,
            title: 'No folders yet',
            subtitle: 'Create a folder to organize your vocabulary.',
            actionLabel: 'Create folder',
            onAction: () => _showCreateFolderDialog(context),
          ),
        ),
      ],
      FoldersLoaded(folders: final folders) => [
        SliverToBoxAdapter(
          child: VocabularyHeader(
            folderCount: folders.length,
            totalTermsCount: folders.fold<int>(0, (s, i) => s + i.termCount),
          ),
        ),
        FolderGrid(
          folders: folders,
          onTap: (f) => _openFolder(context, f),
          onRename: (f) => _showRenameFolderDialog(context, f),
          onDelete: (f) => _confirmDeleteFolder(context, f),
        ),
      ],
      FolderLoading() => const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      FolderFailure(message: final message) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyMessage(
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong',
            subtitle: message,
            actionLabel: 'Try again',
            onAction: () => context.read<FolderCubit>().loadFolders(),
          ),
        ),
      ],
      _ => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyMessage(
            icon: Icons.folder_outlined,
            title: 'Your vocabulary folders',
            subtitle: 'Create folders to organize your words.',
            actionLabel: 'Load folders',
            onAction: () => context.read<FolderCubit>().loadFolders(),
          ),
        ),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isTablet ? 850 : double.infinity,
          ),
          child: BlocBuilder<FolderCubit, FolderState>(
            // Refreshing keeps the current list on screen instead of
            // flashing a spinner.
            buildWhen: (prev, current) {
              if (current is FolderLoading && prev is FoldersLoaded) {
                return false;
              }
              return current is FolderLoading ||
                  current is FoldersLoaded ||
                  current is FolderFailure ||
                  current is FolderInitial;
            },
            builder: (context, state) => RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: _slivers(context, state),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateFolderDialog(context),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New folder'),
      ),
    );
  }
}
