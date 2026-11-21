import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/vocabulary_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/pages/vocabulary_detail.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/folder_picker_sheet.dart';

class SyncedVocabularyPage extends StatefulWidget {
  const SyncedVocabularyPage({super.key});

  @override
  State<SyncedVocabularyPage> createState() => _SyncedVocabularyPageState();
}

class _SyncedVocabularyPageState extends State<SyncedVocabularyPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<VocabularyCubit>().getAllTerms();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _searchQuery = val.trim().toLowerCase();
        });
      }
    });
  }

  void _onSaveToFolder(BuildContext context, Term term) async {
    final selectedFolder = await FolderPickerSheet.show(
      context,
      termWord: term.termWord,
    );

    if (selectedFolder != null && context.mounted) {
      await AppDatabase.instance.saveTermToFolder(
        term: term,
        folderId: selectedFolder.id,
      );
      if (context.mounted) {
        context.read<FolderCubit>().loadFolders();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Saved "${term.termWord}" to "${selectedFolder.name}"',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
      }
    }
  }

  Future<void> _confirmDeleteOnlineTerm(BuildContext context, Term term) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Synced Term?'),
        content: Text(
          'Are you sure you want to delete "${term.termWord}" from cloud storage?\n\n'
          'This action removes it from your synced vocabulary across devices.',
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
      context.read<VocabularyCubit>().deleteTermById(term.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Synced Vocabulary'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sync with cloud',
            icon: const Icon(Icons.sync_rounded),
            onPressed: () => context.read<VocabularyCubit>().getAllTerms(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isTablet ? 800 : double.infinity,
            ),
            child: BlocConsumer<VocabularyCubit, VocabularyState>(
              listenWhen: (_, current) =>
                  current is VocabularyFailure || current is TermSavedSuccess,
              listener: (context, state) {
                if (state is VocabularyFailure) {
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
              builder: (context, state) {
                final isLoading =
                    state is VocabularyLoading || state is VocabularyInitial;
                final allTerms = switch (state) {
                  VocabularyLoaded(terms: final t) => t,
                  _ =>
                    isLoading
                        ? List.generate(
                            4,
                            (i) => Term(
                              id: i,
                              termWord: 'Loading term',
                              termDefinitions: {
                                TermDefinition(
                                  id: i,
                                  definition:
                                      'Loading definition placeholder...',
                                ),
                              },
                              termExamples: {},
                              exampleDefinitions: {},
                            ),
                          )
                        : <Term>[],
                };

                final filteredTerms = _searchQuery.isEmpty
                    ? allTerms
                    : allTerms.where((t) {
                        final wordMatch = t.termWord.toLowerCase().contains(
                          _searchQuery,
                        );
                        final defMatch = t.termDefinitions.any(
                          (d) =>
                              d.definition.toLowerCase().contains(_searchQuery),
                        );
                        return wordMatch || defMatch;
                      }).toList();

                return Column(
                  children: [
                    // Search & Filter header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search synced terms...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _debounceTimer?.cancel();
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest.withValues(
                            alpha: 0.4,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    // Main Content
                    Expanded(
                      child: Skeletonizer(
                        enabled: isLoading,
                        effect: ShimmerEffect(
                          baseColor: Colors.white.withValues(alpha: 0.15),
                          highlightColor: Colors.white.withValues(alpha: 0.35),
                        ),
                        child: allTerms.isEmpty && !isLoading
                            ? _EmptyCloudMessage(
                                key: const ValueKey('empty_cloud'),
                                onRefresh: () => context
                                    .read<VocabularyCubit>()
                                    .getAllTerms(),
                              )
                            : filteredTerms.isEmpty && !isLoading
                            ? Center(
                                key: const ValueKey('empty_search'),
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 48,
                                        color: scheme.outline,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No terms found for "$_searchQuery"',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  24,
                                ),
                                itemCount: filteredTerms.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final term = filteredTerms[index];
                                  return _SyncedTermTile(
                                    term: term,
                                    onSaveToFolder: () =>
                                        _onSaveToFolder(context, term),
                                    onDelete: () =>
                                        _confirmDeleteOnlineTerm(context, term),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCloudMessage extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyCloudMessage({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: scheme.outline),
            const SizedBox(height: 12),
            const Text(
              'No synced terms',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Translate words or phrases to save them to the cloud.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.3),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRefresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncedTermTile extends StatelessWidget {
  final Term term;
  final VoidCallback onSaveToFolder;
  final VoidCallback onDelete;

  const _SyncedTermTile({
    required this.term,
    required this.onSaveToFolder,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);
    final firstDefinition = term.termDefinitions.isNotEmpty
        ? term.termDefinitions.first.definition
        : '';

    return Slidable(
      key: ValueKey('synced_${term.id}'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: scheme.errorContainer,
            foregroundColor: scheme.onErrorContainer,
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            borderRadius: radius,
          ),
        ],
      ),
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => VocabularyDetail.show(context, term),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        term.termWord,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (firstDefinition.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          firstDefinition,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Save to folder',
                  icon: const Icon(Icons.bookmark_add_outlined),
                  onPressed: onSaveToFolder,
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
