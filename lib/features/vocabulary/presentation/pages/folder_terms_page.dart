import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/add_term_dialog.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/folder_term_tile.dart';

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
      builder: (_) => AddTermDialog(folderName: widget.folder.name),
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isTablet ? 800 : double.infinity,
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
                          return FolderTermTile(
                            term: term,
                            folderId: widget.folder.id,
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTermDialog(context),
        tooltip: 'Add term to folder',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
