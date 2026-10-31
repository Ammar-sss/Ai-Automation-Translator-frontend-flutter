import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator/core/router/route_name.dart';
import 'package:smart_translator/features/vocabulary/data/models/term.dart';
import 'package:smart_translator/features/vocabulary/domain/repositories/vocabulary_repository.dart';
import 'package:smart_translator/features/vocabulary/presentation/controllers/vocabulary_cubit.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          VocabularyCubit(context.read<VocabularyRepository>()),
      child: const _VocabularyView(),
    );
  }
}

class _VocabularyView extends StatefulWidget {
  const _VocabularyView();

  @override
  State<_VocabularyView> createState() => _VocabularyViewState();
}

class _VocabularyViewState extends State<_VocabularyView> {
  int _filterIndex = 0; // 0: All, 1: Pending, 2: Synced
  bool _isSearching = false;
  bool _isSyncing = false;
  final double _syncProgress = 0.65;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<VocabularyCubit>().load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddTermDialog(BuildContext context) {
    final wordController = TextEditingController();
    final defController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1F2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add Term Manually',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wordController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Word or phrase',
                  hintStyle: const TextStyle(color: Color(0xFFAB8981)),
                  filled: true,
                  fillColor: const Color(0xFF282935),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: defController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Definition',
                  hintStyle: const TextStyle(color: Color(0xFFAB8981)),
                  filled: true,
                  fillColor: const Color(0xFF282935),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFAB8981)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5A2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<VocabularyCubit>().load();
              },
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF11131D);
    const containerColor = Color(0xFF1E1F2A);
    const borderColor = Color(0xFF282935);
    const primaryOrange = Color(0xFFFF5A2C);
    const successGreen = Color(0xFF4AE183);
    const pendingGold = Color(0xFFFFB020);
    const textMuted = Color(0xFFAB8981);

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryOrange,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () => _showAddTermDialog(context),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: BlocConsumer<VocabularyCubit, VocabularyState>(
          listener: (context, state) {
            if (state is VocabularyFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            List<Term> allTerms = [];
            if (state is VocabularyLoaded) {
              allTerms = state.terms;
            }

            final pendingCount = 3;
            final syncedCount = allTerms.length;
            final totalCount = allTerms.length + pendingCount;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar (Title, Count, Search, Sync buttons)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Vocabulary',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($totalCount)',
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                          });
                        },
                        icon: const Icon(
                          Icons.search_rounded,
                          color: Colors.white70,
                          size: 22,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isSyncing = !_isSyncing;
                          });
                          context.read<VocabularyCubit>().load();
                        },
                        icon: Icon(
                          _isSyncing ? Icons.sync_rounded : Icons.sync_rounded,
                          color: _isSyncing ? primaryOrange : Colors.white70,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Field (Shown when search icon is tapped)
                if (_isSearching)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search terms...',
                        hintStyle: const TextStyle(color: textMuted),
                        prefixIcon: const Icon(Icons.search, color: textMuted),
                        filled: true,
                        fillColor: containerColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                // Syncing Progress Banner (Shown when syncing)
                if (_isSyncing)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryOrange,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Syncing 3 terms to cloud...',
                                  style: TextStyle(
                                    color: primaryOrange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${(_syncProgress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _syncProgress,
                            backgroundColor: const Color(0xFF14151E),
                            color: primaryOrange,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Filter Pills Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _FilterPill(
                        label: 'All ($totalCount)',
                        isSelected: _filterIndex == 0,
                        activeColor: primaryOrange,
                        onTap: () => setState(() => _filterIndex = 0),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Pending ($pendingCount)',
                        isSelected: _filterIndex == 1,
                        activeColor: pendingGold,
                        onTap: () => setState(() => _filterIndex = 1),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Synced ($syncedCount)',
                        isSelected: _filterIndex == 2,
                        activeColor: successGreen,
                        onTap: () => setState(() => _filterIndex = 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Term List or Empty State
                Expanded(
                  child:
                      (state is VocabularyLoading || state is VocabularyInitial)
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryOrange,
                          ),
                        )
                      : allTerms.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: allTerms.length,
                          itemBuilder: (context, index) {
                            final term = allTerms[index];
                            return _buildTermItem(context, term, index);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    const primaryOrange = Color(0xFFFF5A2C);
    const textMuted = Color(0xFFAB8981);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Book Hero Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1F2A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF282935), width: 1.5),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: primaryOrange,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'No terms yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Start translating words and save them to build your personal vocabulary deck.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 32),

            // Translate a Word CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: () => context.go(RouteName.home),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Translate a word',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              '⊕ or tap + to enter a term manually',
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(BuildContext context, Term term, int index) {
    const containerColor = Color(0xFF1E1F2A);
    const borderColor = Color(0xFF282935);
    const successGreen = Color(0xFF4AE183);
    const pendingGold = Color(0xFFFFB020);
    const textMuted = Color(0xFFAB8981);

    final word = term.termWord ?? 'Term';
    final def =
        (term.termDefinitions != null && term.termDefinitions!.isNotEmpty)
        ? term.termDefinitions!.first.definition ?? ''
        : 'Definition';

    final isSynced = index % 2 == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Dismissible(
        key: Key('term_${term.id ?? index}'),
        background: Container(
          decoration: BoxDecoration(
            color: pendingGold,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: const [
              Icon(Icons.edit_rounded, color: Colors.black, size: 20),
              SizedBox(width: 6),
              Text(
                'UPDATE',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                'DELETE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
        onDismissed: (direction) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                direction == DismissDirection.startToEnd
                    ? 'Updating $word'
                    : 'Deleted $word',
              ),
            ),
          );
        },
        child: GestureDetector(
          onTap: () => context.push(RouteName.termDetails, extra: term),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            word,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'noun',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        def,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFE4BEB5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Sync Status Badge
                if (isSynced)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2A22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: successGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: successGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.check_rounded,
                          color: successGreen,
                          size: 12,
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF332A18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pendingGold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: pendingGold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.cloud_outlined,
                          color: pendingGold,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFF1E1F2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFF282935),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
