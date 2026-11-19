import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/vocabulary_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/pages/vocabulary_detail.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<VocabularyCubit, VocabularyState>(
          listenWhen: (previous, current) =>
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
          buildWhen: (previous, current) =>
              current is VocabularyLoading ||
              current is VocabularyLoaded ||
              current is VocabularyFailure ||
              current is VocabularyInitial,
          builder: (context, state) {
            final count = state is VocabularyLoaded ? state.terms.length : null;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(count: count),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: switch (state) {
                        VocabularyLoading() => const Center(
                          key: ValueKey('loading'),
                          child: CircularProgressIndicator(),
                        ),
                        VocabularyLoaded(terms: final terms) =>
                          terms.isEmpty
                              ? const _Message(
                                  key: ValueKey('empty'),
                                  icon: Icons.menu_book_outlined,
                                  title: 'No words saved yet',
                                  subtitle: 'Translate a word and save it to build your list.',
                                )
                              : _TermList(
                                  key: const ValueKey('list'),
                                  terms: terms,
                                ),
                        VocabularyFailure(message: final message) => _Message(
                          key: const ValueKey('error'),
                          icon: Icons.error_outline_rounded,
                          title: 'Couldn’t load vocabulary',
                          subtitle: message,
                          actionLabel: 'Try again',
                          onAction: () =>
                              context.read<VocabularyCubit>().getAllTerms(),
                        ),
                        _ => _Message(
                          key: const ValueKey('initial'),
                          icon: Icons.menu_book_outlined,
                          title: 'Your vocabulary',
                          subtitle: 'Load your saved words.',
                          actionLabel: 'Load words',
                          onAction: () =>
                              context.read<VocabularyCubit>().getAllTerms(),
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
    );
  }
}

// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final int? count;
  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
              if (count != null)
                Text(
                  count == 1 ? '1 word' : '$count words',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Refresh',
          onPressed: () => context.read<VocabularyCubit>().getAllTerms(),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _TermList extends StatelessWidget {
  final List<Term> terms;
  const _TermList({super.key, required this.terms});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: terms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final term = terms[index];
        return _TermTile(key: ValueKey(term.id), term: term);
      },
    );
  }
}

class _TermTile extends StatelessWidget {
  final Term term;
  const _TermTile({super.key, required this.term});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);
    final firstDefinition = term.termDefinitions.isNotEmpty
        ? term.termDefinitions.first.definition
        : '';

    return Slidable(
      key: ValueKey(term.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Edit ${term.termWord}')));
            },
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            icon: Icons.edit_outlined,
            label: 'Edit',
            borderRadius: radius,
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) =>
                context.read<VocabularyCubit>().deleteTermById(term.id),
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
                Icon(Icons.chevron_right_rounded, color: scheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({
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
