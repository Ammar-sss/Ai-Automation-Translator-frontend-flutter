import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/pages/vocabulary_detail.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/term_tile.dart';

class FolderTermTile extends StatelessWidget {
  final Term term;
  final int folderId;

  const FolderTermTile({super.key, required this.term, required this.folderId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Slidable(
      key: ValueKey('${term.id}_$folderId'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (_) => context.read<FolderCubit>().removeTermFromFolder(
              termId: term.id,
              folderId: folderId,
              termWord: term.termWord,
            ),
            backgroundColor: scheme.errorContainer,
            foregroundColor: scheme.onErrorContainer,
            icon: Icons.remove_circle_outline_rounded,
            label: 'Remove',
            borderRadius: TermTile.radius,
          ),
        ],
      ),
      child: TermTile(
        term: term,
        onTap: () => VocabularyDetail.show(context, term),
      ),
    );
  }
}
