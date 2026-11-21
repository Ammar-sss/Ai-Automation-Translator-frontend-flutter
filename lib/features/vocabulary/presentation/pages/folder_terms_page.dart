import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name)),
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
                terms: terms,
                folderId: widget.folder.id,
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

class _TermList extends StatelessWidget {
  final List<Term> terms;
  final int folderId;
  final bool scrollable;

  const _TermList({
    required this.terms,
    required this.folderId,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: scrollable
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: terms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => FolderTermTile(term: terms[i], folderId: folderId),
    );
  }
}
