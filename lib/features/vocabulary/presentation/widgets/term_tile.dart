import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/app_snackbar.dart';
import 'package:smart_translator_test/core/network/network_cubit.dart';
import 'package:smart_translator_test/core/network/server_health_cubit.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/core/util/translation_language.dart';
import 'package:smart_translator_test/core/widgets/pulsing_dot.dart';
import 'package:smart_translator_test/core/widgets/radio_wave_dot.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/save_term_request.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/vocabulary_cubit.dart';

enum _SyncStatus { synced, syncing, notSynced, error }

/// Shared row used by both the folder page and the synced page.
class TermTile extends StatefulWidget {
  final Term term;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TermTile({super.key, required this.term, this.onTap, this.trailing});

  static const radius = BorderRadius.all(Radius.circular(16));

  /// Built once, reused by every skeleton/loading state.
  static final List<Term> placeholders = List.generate(
    5,
    (i) => Term(
      id: i,
      termWord: 'Loading term',
      termDefinitions: {
        TermDefinition(id: i, definition: 'Loading definition placeholder...'),
      },
      termExamples: {},
      exampleDefinitions: {},
    ),
    growable: false,
  );

  @override
  State<TermTile> createState() => _TermTileState();
}

class _TermTileState extends State<TermTile> {
  late _SyncStatus _syncStatus;

  @override
  void initState() {
    super.initState();
    _syncStatus = _resolveInitialStatus();
  }

  _SyncStatus _resolveInitialStatus() {
    if (widget.term.id > 0) return _SyncStatus.synced;
    try {
      final vocabCubit = context.read<VocabularyCubit>();
      if (vocabCubit.isTermSavedOnline(
        widget.term.termWord,
        sourceLanguage: widget.term.sourceLanguage,
        targetLanguage: widget.term.targetLanguage,
      )) {
        return _SyncStatus.synced;
      }
    } catch (_) {}
    return _SyncStatus.notSynced;
  }

  @override
  void didUpdateWidget(TermTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.term.id > 0) {
      _syncStatus = _SyncStatus.synced;
    } else if (_syncStatus != _SyncStatus.syncing &&
        _syncStatus != _SyncStatus.error) {
      _syncStatus = _resolveInitialStatus();
    }
  }

  Future<void> _syncTerm() async {
    if (_syncStatus == _SyncStatus.syncing) return;

    // 1. Check internet connection first
    try {
      final networkCubit = context.read<NetworkCubit>();
      if (networkCubit.state is NetworkDisconnected) {
        setState(() {
          _syncStatus = _SyncStatus.error;
        });
        showAppSnackBar(
          context,
          'Sync failed: No internet connection',
          isError: true,
        );
        return;
      }
    } catch (_) {}

    // 2. Check server status using ServerHealthCubit (just like ServerStatusIndicator)
    ServerHealthCubit? serverHealthCubit;
    try {
      serverHealthCubit = context.read<ServerHealthCubit>();
    } catch (_) {}

    final bool isSleeping = serverHealthCubit?.state is ServerSleeping;
    if (isSleeping && serverHealthCubit != null) {
      serverHealthCubit.wakeServer();
    }

    // Set UI to syncing (shows pulsing amber dot like ServerStatusIndicator waking up)
    setState(() {
      _syncStatus = _SyncStatus.syncing;
    });

    final saveTermRequest = SaveTermRequest(
      termWord: widget.term.termWord,
      sourceLanguage: TranslationLanguage.values.firstWhere(
        (l) => l.backendValue == widget.term.sourceLanguage,
        orElse: () => TranslationLanguage.english,
      ),
      targetLanguage: TranslationLanguage.values.firstWhere(
        (l) => l.backendValue == widget.term.targetLanguage,
        orElse: () => TranslationLanguage.arabic,
      ),
      exampleSentence: widget.term.termExamples.isNotEmpty
          ? widget.term.termExamples.first.exampleSentence
          : '',
      termDefinitions: widget.term.termDefinitions
          .map((d) => d.definition)
          .toSet(),
      exampleDefinition: widget.term.exampleDefinitions.isNotEmpty
          ? widget.term.exampleDefinitions.first.exampleDefinition
          : '',
    );

    try {
      final vocabCubit = context.read<VocabularyCubit>();
      final savedTerm = await vocabCubit.confirmTermSave(saveTermRequest);

      final onlineTerm =
          savedTerm ??
          vocabCubit.getSavedOnlineTerm(
            widget.term.termWord,
            sourceLanguage: widget.term.sourceLanguage,
            targetLanguage: widget.term.targetLanguage,
          );
      if (onlineTerm != null && onlineTerm.id > 0) {
        await AppDatabase.instance.updateTerm(onlineTerm);
      }

      if (mounted) {
        setState(() {
          _syncStatus = _SyncStatus.synced;
        });
        showAppSnackBar(
          context,
          'Synced "${widget.term.termWord}" online successfully',
        );
      }
    } catch (e) {
      serverHealthCubit?.wakeServer();

      if (mounted) {
        setState(() {
          _syncStatus = _SyncStatus.error;
        });

        final rawError = e.toString().replaceAll("Exception: ", "");
        final String errorMessage =
            'Sync failed: $rawError (Server might be waking up, please retry)';

        showAppSnackBar(context, errorMessage, isError: true);
      }
    }
  }

  Widget _buildSyncBadge(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPlaceholder = widget.term.termWord == 'Loading term';
    if (isPlaceholder) return const SizedBox.shrink();

    final Color dotColor;
    final Color textColor;
    final Color backgroundColor;
    final String text;
    final bool isSynced = _syncStatus == _SyncStatus.synced;
    final bool isSyncing = _syncStatus == _SyncStatus.syncing;
    final bool isError = _syncStatus == _SyncStatus.error;
    final VoidCallback? onTap;

    if (isSynced) {
      dotColor = Colors.green;
      textColor = scheme.onSurface;
      backgroundColor = scheme.surfaceContainerHigh;
      text = 'Synced';
      onTap = null;
    } else if (isSyncing) {
      dotColor = Colors.amber;
      textColor = scheme.onSurface;
      backgroundColor = scheme.surfaceContainerHigh;
      text = 'Syncing…';
      onTap = null;
    } else if (isError) {
      dotColor = scheme.error;
      textColor = scheme.error;
      backgroundColor = scheme.errorContainer.withValues(alpha: 0.35);
      text = 'Failed';
      onTap = _syncTerm;
    } else {
      dotColor = Colors.amber;
      textColor = scheme.onSurfaceVariant;
      backgroundColor = scheme.surfaceContainerHigh;
      text = 'Not synced';
      onTap = _syncTerm;
    }

    Widget buildDot() {
      if (isSynced) {
        return const RadioWaveDot(color: Colors.green, size: 7, maxScale: 2.2);
      }
      if (isSyncing) {
        return const PulsingDot(
          color: Colors.amber,
          size: 7,
          minSize: 0.7,
          maxSize: 1.4,
        );
      }
      return Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      );
    }

    return BlocListener<VocabularyCubit, VocabularyState>(
      listener: (context, state) {
        if (_syncStatus == _SyncStatus.syncing) return;
        final vocabCubit = context.read<VocabularyCubit>();
        if (vocabCubit.isTermSavedOnline(
          widget.term.termWord,
          sourceLanguage: widget.term.sourceLanguage,
          targetLanguage: widget.term.targetLanguage,
        )) {
          if (_syncStatus != _SyncStatus.synced) {
            setState(() {
              _syncStatus = _SyncStatus.synced;
            });
            final onlineTerm = vocabCubit.getSavedOnlineTerm(
              widget.term.termWord,
              sourceLanguage: widget.term.sourceLanguage,
              targetLanguage: widget.term.targetLanguage,
            );
            if (onlineTerm != null && onlineTerm.id > 0) {
              AppDatabase.instance.updateTerm(onlineTerm);
            }
          }
        }
      },
      child: Semantics(
        button: onTap != null,
        label: 'Sync status: $text',
        child: Material(
          color: backgroundColor,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: Center(child: buildDot()),
                  ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      text,
                      key: ValueKey('$text-$isError'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final definition = widget.term.termDefinitions.isNotEmpty
        ? widget.term.termDefinitions.first.definition
        : '';

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: TermTile.radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.term.termWord,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (definition.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        definition,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              widget.trailing ?? _buildSyncBadge(context),
            ],
          ),
        ),
      ),
    );
  }
}
