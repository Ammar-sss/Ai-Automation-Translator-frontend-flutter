import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/pages/vocabulary_detail.dart';

/// Displays all terms inside a specific folder with the ability to add terms directly.
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
    // Load terms in folder every time the page is navigated to
    context.read<FolderCubit>().loadTermsInFolder(widget.folder.id);
  }

  Future<void> _showAddTermDialog(BuildContext context) async {
    final term = await showDialog<Term>(
      context: context,
      builder: (_) => _AddTermDialog(folderName: widget.folder.name),
    );

    if (term != null && context.mounted) {
      context.read<FolderCubit>().saveTermToFolder(
        term: term,
        folderId: widget.folder.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Add Term',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddTermDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<FolderCubit, FolderState>(
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
            current is FolderTermsLoading || current is FolderTermsLoaded,
        builder: (context, state) {
          final isLoading = state is FolderTermsLoading;
          final terms = switch (state) {
            FolderTermsLoaded(terms: final t) => t,
            FolderTermsLoading() => List.generate(
              3,
              (i) => Term(
                id: i,
                termWord: 'Loading term',
                termDefinitions: {
                  TermDefinition(
                    id: i,
                    definition: 'Loading definition placeholder text...',
                  ),
                },
                termExamples: {},
                exampleDefinitions: {},
              ),
            ),
            _ => <Term>[],
          };

          return Skeletonizer(
            enabled: isLoading,
            effect: ShimmerEffect(
              baseColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.35),
            ),
            child: terms.isEmpty && !isLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 48,
                            color: scheme.outline,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No terms in this folder',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add terms using the button below or by translating.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: () => _showAddTermDialog(context),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add term'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: terms.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final term = terms[index];
                      return _FolderTermTile(
                        term: term,
                        folderId: widget.folder.id,
                      );
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTermDialog(context),
        tooltip: 'Add term to folder',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Term Dialog (Stateful to safely manage controller lifecycle)
// ---------------------------------------------------------------------------

class _AddTermDialog extends StatefulWidget {
  final String folderName;

  const _AddTermDialog({required this.folderName});

  @override
  State<_AddTermDialog> createState() => _AddTermDialogState();
}

class _AddTermDialogState extends State<_AddTermDialog> {
  late final TextEditingController _wordController;
  late final TextEditingController _definitionController;
  late final TextEditingController _exampleController;
  late final TextEditingController _exampleDefinitionController;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController();
    _definitionController = TextEditingController();
    _exampleController = TextEditingController();
    _exampleDefinitionController = TextEditingController();
  }

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _exampleDefinitionController.dispose();
    super.dispose();
  }

  void _submit() {
    final word = _wordController.text.trim();
    if (word.isEmpty) return;

    final defText = _definitionController.text.trim();
    final exText = _exampleController.text.trim();
    final exDefText = _exampleDefinitionController.text.trim();

    final term = Term(
      id: 0,
      termWord: word,
      termDefinitions: defText.isNotEmpty
          ? {TermDefinition(id: 0, definition: defText)}
          : {},
      termExamples: exText.isNotEmpty
          ? {Example(id: 0, exampleSentence: exText)}
          : {},
      exampleDefinitions: exDefText.isNotEmpty
          ? {ExampleDefinition(id: 0, exampleDefinition: exDefText)}
          : {},
    );

    Navigator.pop(context, term);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Term to ${widget.folderName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _wordController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Term / Word *',
                hintText: 'e.g. sister',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _definitionController,
              decoration: const InputDecoration(
                labelText: 'Definition (optional)',
                hintText: 'e.g. A female sibling',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exampleController,
              decoration: const InputDecoration(
                labelText: 'Example sentence (optional)',
                hintText: 'e.g. My sister is older than me',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exampleDefinitionController,
              decoration: const InputDecoration(
                labelText: 'Example definition (optional)',
                hintText: 'e.g. اختي أكبر مني سنًا',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _FolderTermTile extends StatelessWidget {
  final Term term;
  final int folderId;

  const _FolderTermTile({required this.term, required this.folderId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);
    final firstDefinition = term.termDefinitions.isNotEmpty
        ? term.termDefinitions.first.definition
        : '';

    return Slidable(
      key: ValueKey('${term.id}_$folderId'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) {
              context.read<FolderCubit>().removeTermFromFolder(
                termId: term.id,
                folderId: folderId,
              );
            },
            backgroundColor: scheme.errorContainer,
            foregroundColor: scheme.onErrorContainer,
            icon: Icons.remove_circle_outline_rounded,
            label: 'Remove',
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
