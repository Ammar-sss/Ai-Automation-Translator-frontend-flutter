import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/features/practice/presentation/pages/practice_page.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/add_term_dialog.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/empty_message.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/folder_term_tile.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/term_tile.dart';

import '../../../../app_snackbar.dart';

/// All terms inside one folder.
class FolderTermsPage extends StatefulWidget {
  final Folder folder;

  const FolderTermsPage({super.key, required this.folder});

  @override
  State<FolderTermsPage> createState() => _FolderTermsPageState();
}

class _FolderTermsPageState extends State<FolderTermsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FolderCubit>().loadTermsInFolder(widget.folder.id);
  }

  Future<void> _showAddTermDialog() async {
    final term = await showDialog<Term>(
      context: context,
      builder: (_) => AddTermDialog(folderName: widget.folder.name),
    );
    if (term != null && mounted) {
      context.read<FolderCubit>().saveTermToFolder(
        term: term,
        folderId: widget.folder.id,
      );
    }
  }

  void _startPractice(List<Term> terms) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PracticePage(folder: widget.folder, initialTerms: terms),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        actions: [
          BlocBuilder<FolderCubit, FolderState>(
            buildWhen: (_, current) => current is FolderTermsLoaded,
            builder: (context, state) {
              final terms = state is FolderTermsLoaded ? state.terms : <Term>[];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton.tonalIcon(
                  onPressed: () => _startPractice(terms),
                  icon: const Icon(Icons.style_rounded, size: 18),
                  label: const Text('Practice'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isTablet ? 800 : double.infinity,
          ),
          child: BlocConsumer<FolderCubit, FolderState>(
            listenWhen: (_, current) => current is FolderFailure,
            listener: (context, state) {
              if (state is FolderFailure) {
                showAppSnackBar(context, state.message, isError: true);
              }
            },
            buildWhen: (_, current) =>
                current is FolderTermsLoading || current is FolderTermsLoaded,
            builder: (context, state) => switch (state) {
              FolderTermsLoading() => Skeletonizer(
                child: _TermList(
                  folder: widget.folder,
                  terms: TermTile.placeholders,
                  folderId: widget.folder.id,
                  scrollable: false,
                ),
              ),
              FolderTermsLoaded(terms: final terms) when terms.isEmpty =>
                EmptyMessage(
                  icon: Icons.folder_open_rounded,
                  title: 'No terms yet',
                  subtitle: 'Add a term here or save one from a translation.',
                  actionLabel: 'Add term',
                  onAction: _showAddTermDialog,
                ),
              FolderTermsLoaded(terms: final terms) => _TermList(
                folder: widget.folder,
                terms: terms,
                folderId: widget.folder.id,
                onPractice: () => _startPractice(terms),
              ),
              _ => const SizedBox.shrink(),
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTermDialog,
        tooltip: 'Add term',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _PracticeHeaderCard extends StatelessWidget {
  final Folder folder;
  final int termCount;
  final VoidCallback onPractice;

  const _PracticeHeaderCard({
    required this.folder,
    required this.termCount,
    required this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.style_rounded, color: scheme.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice ${folder.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$termCount ${termCount == 1 ? 'term' : 'terms'} ready for review',
                  style: text.bodySmall?.copyWith(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onPractice,
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: const Text('Start'),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermList extends StatelessWidget {
  final Folder folder;
  final List<Term> terms;
  final int folderId;
  final bool scrollable;
  final VoidCallback? onPractice;

  const _TermList({
    required this.folder,
    required this.terms,
    required this.folderId,
    this.scrollable = true,
    this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    final showHeader = onPractice != null && terms.isNotEmpty;
    final totalCount = showHeader ? terms.length + 1 : terms.length;

    return ListView.separated(
      physics: scrollable
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: totalCount,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        if (showHeader && i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PracticeHeaderCard(
              folder: folder,
              termCount: terms.length,
              onPractice: onPractice!,
            ),
          );
        }
        final termIndex = showHeader ? i - 1 : i;
        return FolderTermTile(term: terms[termIndex], folderId: folderId);
      },
    );
  }
}
