import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator_test/core/route/app_routes.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/features/user/presentation/controller/user_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/vocabulary_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/pages/folder_terms_page.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/pages/vocabulary_detail.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Term> _recentTerms = [];
  Term? _wordOfTheDay;
  bool _isLoadingRecent = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final allTerms = await AppDatabase.instance.getAllTerms();
      if (!mounted) return;

      setState(() {
        _recentTerms = allTerms.reversed.take(5).toList();
        if (allTerms.isNotEmpty) {
          // Stable random pick for the day based on day of the year
          final dayIndex = DateTime.now().day % allTerms.length;
          _wordOfTheDay = allTerms[dayIndex];
        } else {
          _wordOfTheDay = null;
        }
        _isLoadingRecent = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingRecent = false);
      }
    }
  }

  void _openFolder(Folder folder) {
    context.read<FolderCubit>().loadTermsInFolder(folder.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FolderTermsPage(folder: folder)),
    ).then((_) {
      if (mounted) {
        context.read<FolderCubit>().loadFolders();
        _loadDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FolderCubit>().loadFolders();
        context.read<VocabularyCubit>().getAllTerms();
        await _loadDashboardData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          context.wp(4),
          context.hp(1),
          context.wp(4),
          context.hp(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Personalized Greeting
            _GreetingHeader(),
            SizedBox(height: context.hp(2)),

            // 2. Word of the Day (or Get Started banner)
            _WordOfTheDayCard(
              term: _wordOfTheDay,
              onTap: _wordOfTheDay != null
                  ? () => VocabularyDetail.show(context, _wordOfTheDay!)
                  : null,
            ),
            SizedBox(height: context.hp(2.5)),

            // 3. Quick Action Shortcuts
            _QuickActionsSection(),
            SizedBox(height: context.hp(2.5)),

            // 4. Progress Statistics
            _StatsOverview(recentTermsCount: _recentTerms.length),
            SizedBox(height: context.hp(2.5)),

            // 5. Recent Folders
            _RecentFoldersSection(onFolderTap: _openFolder),
            SizedBox(height: context.hp(2.5)),

            // 6. Recently Added Words
            _RecentWordsSection(
              isLoading: _isLoadingRecent,
              terms: _recentTerms,
              onTermTap: (term) => VocabularyDetail.show(context, term),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Greeting Header
// ---------------------------------------------------------------------------

class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12
        ? 'Good morning'
        : (hour < 17 ? 'Good afternoon' : 'Good evening');

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        final name = state is UserLoaded && state.user.username.isNotEmpty
            ? state.user.username
            : null;

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name != null
                        ? '$timeGreeting, $name 👋'
                        : '$timeGreeting 👋',
                    style: TextStyle(
                      fontSize: context.sp(22, min: 20, max: 26),
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Ready to expand your vocabulary today?',
                    style: TextStyle(
                      fontSize: context.sp(14, min: 12, max: 15),
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Word of the Day Card
// ---------------------------------------------------------------------------

class _WordOfTheDayCard extends StatelessWidget {
  final Term? term;
  final VoidCallback? onTap;

  const _WordOfTheDayCard({required this.term, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (term == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer,
              scheme.secondaryContainer.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: scheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'WELCOME TO SMART TRANSLATOR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Translate & organize your words',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Translate any word with AI to see definitions, examples, and organize into folders.',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onPrimaryContainer.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.tonal(
              onPressed: () => context.go(AppRoutes.translate),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.surface,
                foregroundColor: scheme.primary,
              ),
              child: const Text('Start translating'),
            ),
          ],
        ),
      );
    }

    final firstDefinition = term!.termDefinitions.isNotEmpty
        ? term!.termDefinitions.first.definition
        : '';
    final firstExample = term!.termExamples.isNotEmpty
        ? term!.termExamples.first.exampleSentence
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primaryContainer,
                scheme.primaryContainer.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: scheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'WORD OF THE DAY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: scheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.primary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                term!.termWord,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              if (firstDefinition.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  firstDefinition,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.9),
                    height: 1.3,
                  ),
                ),
              ],
              if (firstExample.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '"$firstExample"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Quick Action Shortcuts
// ---------------------------------------------------------------------------

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.translate_rounded,
            title: 'Translate',
            subtitle: 'AI translation',
            color: scheme.primary,
            containerColor: scheme.primaryContainer.withValues(alpha: 0.5),
            onTap: () => context.go(AppRoutes.translate),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.folder_special_rounded,
            title: 'Folders',
            subtitle: 'Organize words',
            color: scheme.secondary,
            containerColor: scheme.secondaryContainer.withValues(alpha: 0.5),
            onTap: () => context.go(AppRoutes.vocabulary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.cloud_done_rounded,
            title: 'Synced',
            subtitle: 'Cloud terms',
            color: scheme.tertiary,
            containerColor: scheme.tertiaryContainer.withValues(alpha: 0.5),
            onTap: () => context.push(AppRoutes.vocabularySynced),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color containerColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.containerColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Learning Stats Overview
// ---------------------------------------------------------------------------

class _StatsOverview extends StatelessWidget {
  final int recentTermsCount;

  const _StatsOverview({required this.recentTermsCount});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<FolderCubit, FolderState>(
      builder: (context, folderState) {
        final folderCount = folderState is FoldersLoaded
            ? folderState.folders.length
            : 0;

        return BlocBuilder<VocabularyCubit, VocabularyState>(
          builder: (context, vocabState) {
            final syncedCount = vocabState is VocabularyLoaded
                ? vocabState.terms.length
                : 0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Folders',
                    value: '$folderCount',
                    icon: Icons.folder_outlined,
                  ),
                  Container(width: 1, height: 32, color: scheme.outlineVariant),
                  _StatItem(
                    label: 'Recent Words',
                    value: '$recentTermsCount',
                    icon: Icons.bookmark_border_rounded,
                  ),
                  Container(width: 1, height: 32, color: scheme.outlineVariant),
                  _StatItem(
                    label: 'Cloud Synced',
                    value: '$syncedCount',
                    icon: Icons.cloud_outlined,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: scheme.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Recent Folders Section
// ---------------------------------------------------------------------------

class _RecentFoldersSection extends StatelessWidget {
  final ValueChanged<Folder> onFolderTap;

  const _RecentFoldersSection({required this.onFolderTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<FolderCubit, FolderState>(
      builder: (context, state) {
        final folders = state is FoldersLoaded ? state.folders : <FolderInfo>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Your Folders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go(AppRoutes.vocabulary),
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (folders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Center(
                  child: Text(
                    'No folders created yet. Organize your words with folders!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 105,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: folders.take(5).length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = folders[index];
                    return _FolderQuickCard(
                      info: item,
                      onTap: () => onFolderTap(item.folder),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FolderQuickCard extends StatelessWidget {
  final FolderInfo info;
  final VoidCallback onTap;

  const _FolderQuickCard({required this.info, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.folder_rounded, color: scheme.primary, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.folder.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    info.termCount == 1 ? '1 term' : '${info.termCount} terms',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Recently Added Words Section
// ---------------------------------------------------------------------------

class _RecentWordsSection extends StatelessWidget {
  final bool isLoading;
  final List<Term> terms;
  final ValueChanged<Term> onTermTap;

  const _RecentWordsSection({
    required this.isLoading,
    required this.terms,
    required this.onTermTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recently Saved Words',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            if (terms.isNotEmpty)
              Text(
                '${terms.length} latest',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (terms.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Center(
              child: Text(
                'No saved words yet. Start translating and save words here!',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: terms.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final term = terms[index];
              final firstDefinition = term.termDefinitions.isNotEmpty
                  ? term.termDefinitions.first.definition
                  : '';

              return Material(
                color: scheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: scheme.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onTermTap(term),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                term.termWord,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (firstDefinition.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  firstDefinition,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: scheme.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
