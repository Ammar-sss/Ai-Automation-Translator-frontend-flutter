import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/vocabulary_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/pages/vocabulary_detail.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/empty_message.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/folder_picker_sheet.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/term_tile.dart';

import '../../../../app_snackbar.dart';

class SyncedVocabularyPage extends StatefulWidget {
  const SyncedVocabularyPage({super.key});

  @override
  State<SyncedVocabularyPage> createState() => _SyncedVocabularyPageState();
}

class _SyncedVocabularyPageState extends State<SyncedVocabularyPage> {
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<VocabularyCubit>().getAllTerms();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = value.trim().toLowerCase());
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _refresh() async {
    final cubit = context.read<VocabularyCubit>();
    final done = cubit.stream.firstWhere(
      (s) => s is VocabularyLoaded || s is VocabularyFailure,
    );
    cubit.getAllTerms();
    await done.timeout(
      const Duration(seconds: 8),
      onTimeout: () => cubit.state,
    );
  }

  Future<void> _saveToFolder(Term term) async {
    final folder = await FolderPickerSheet.show(
      context,
      termWord: term.termWord,
      sourceLanguage: term.sourceLanguage,
      targetLanguage: term.targetLanguage,
    );
    if (folder == null || !mounted) return;

    await AppDatabase.instance.saveTermToFolder(
      term: term,
      folderId: folder.id,
    );
    if (!mounted) return;
    context.read<FolderCubit>().loadFolders();
    showAppSnackBar(context, 'Saved "${term.termWord}" to "${folder.name}"');
  }

  Future<void> _confirmDelete(Term term) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete synced term?'),
        content: Text(
          '"${term.termWord}" will be removed from the cloud and from all '
          'your devices.',
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
    if (confirmed == true && mounted) {
      context.read<VocabularyCubit>().deleteTermById(term.id);
    }
  }

  bool _matches(Term t) =>
      t.termWord.toLowerCase().contains(_query) ||
      t.termDefinitions.any((d) => d.definition.toLowerCase().contains(_query));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synced vocabulary'),
        actions: [
          IconButton(
            tooltip: 'Sync with cloud',
            icon: const Icon(Icons.sync_rounded),
            onPressed: () => context.read<VocabularyCubit>().getAllTerms(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isTablet ? 800 : double.infinity,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: _clearSearch,
                          ),
                  ),
                ),
              ),
              Expanded(
                child: BlocConsumer<VocabularyCubit, VocabularyState>(
                  listenWhen: (_, current) => current is VocabularyFailure,
                  listener: (context, state) {
                    if (state is VocabularyFailure) {
                      showAppSnackBar(context, state.message, isError: true);
                    }
                  },
                  // Pull-to-refresh keeps the list visible while reloading.
                  buildWhen: (prev, current) =>
                      !(current is VocabularyLoading &&
                          prev is VocabularyLoaded),
                  builder: (context, state) {
                    final isLoading =
                        state is VocabularyLoading ||
                        state is VocabularyInitial;
                    final all = state is VocabularyLoaded
                        ? state.terms
                        : <Term>[];

                    if (isLoading) {
                      return Skeletonizer(
                        child: _buildList(
                          TermTile.placeholders,
                          skeleton: true,
                        ),
                      );
                    }
                    if (all.isEmpty) {
                      return EmptyMessage(
                        icon: Icons.cloud_off_rounded,
                        title: 'No synced terms',
                        subtitle: 'Translate words or phrases to save them to the cloud.',
                        actionLabel: 'Refresh',
                        onAction: () =>
                            context.read<VocabularyCubit>().getAllTerms(),
                      );
                    }

                    final terms = _query.isEmpty
                        ? all
                        : all.where(_matches).toList();
                    if (terms.isEmpty) {
                      return EmptyMessage(
                        icon: Icons.search_off_rounded,
                        title: 'No results',
                        subtitle: 'Nothing matches "$_query".',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: _buildList(terms),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Term> terms, {bool skeleton = false}) {
    final scheme = Theme.of(context).colorScheme;

    return ListView.separated(
      physics: skeleton
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: terms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final term = terms[index];
        return Slidable(
          key: ValueKey('synced_${term.id}'),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.3,
            children: [
              SlidableAction(
                onPressed: (_) => _confirmDelete(term),
                backgroundColor: scheme.errorContainer,
                foregroundColor: scheme.onErrorContainer,
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                borderRadius: TermTile.radius,
              ),
            ],
          ),
          child: TermTile(
            term: term,
            onTap: () => VocabularyDetail.show(context, term),
            trailing: IconButton(
              tooltip: 'Save to folder',
              icon: const Icon(Icons.bookmark_add_outlined),
              onPressed: () => _saveToFolder(term),
            ),
          ),
        );
      },
    );
  }
}
