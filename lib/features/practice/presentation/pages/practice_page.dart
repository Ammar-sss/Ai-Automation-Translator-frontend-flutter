import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/app_snackbar.dart';
import 'package:smart_translator_test/core/network/elevenlabs_service.dart';
import 'package:smart_translator_test/core/route/app_routes.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/core/util/language_detect.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/accuracy_ring_painter.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/empty_deck_illustration.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/glow_box.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/pill.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/practice_card_back.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/practice_card_front.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/practice_rating_controls.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/practice_revealed_controls.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/quick_add_chip.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/summary_metric.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/summary_stat_tile.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/tricky_term_row.dart';
import 'package:smart_translator_test/features/practice/presentation/widgets/user_avatar.dart';

class PracticePage extends StatefulWidget {
  final Folder? folder;
  final List<Term>? initialTerms;

  const PracticePage({super.key, this.folder, this.initialTerms});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage>
    with SingleTickerProviderStateMixin {
  List<Term> _deck = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isFlipped = false;

  // Session stats
  final Set<int> _masteredTermIds = {};
  final List<Term> _trickyTerms = [];
  bool _isSessionFinished = false;
  late DateTime _sessionStartTime;
  Duration _sessionDuration = Duration.zero;

  // Card Flip Animation
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  // Audio TTS
  final ElevenLabsService _elevenLabsService = ElevenLabsService(Dio());
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    _flipController.addListener(() {
      if (_flipController.value >= 0.5 && !_isFlipped) {
        setState(() => _isFlipped = true);
      } else if (_flipController.value < 0.5 && _isFlipped) {
        setState(() => _isFlipped = false);
      }
    });

    _loadDeck();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadDeck() async {
    setState(() => _isLoading = true);

    List<Term> terms = [];
    if (widget.initialTerms != null && widget.initialTerms!.isNotEmpty) {
      terms = List.from(widget.initialTerms!);
    } else if (widget.folder != null) {
      terms = await AppDatabase.instance.getTermsByFolderId(widget.folder!.id);
    } else {
      terms = await AppDatabase.instance.getAllTerms();
    }

    if (!mounted) return;

    setState(() {
      _deck = terms;
      _currentIndex = 0;
      _isLoading = false;
      _isFlipped = false;
      _masteredTermIds.clear();
      _trickyTerms.clear();
      _isSessionFinished = false;
      _sessionStartTime = DateTime.now();
    });

    _flipController.reset();
  }

  void _toggleFlip() {
    if (_flipController.isAnimating) return;
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  Future<void> _speakCurrentTerm(String text) async {
    if (_isPlayingAudio) return;
    setState(() => _isPlayingAudio = true);

    try {
      final code = detectLanguageCode(text) ?? 'en';
      final bytes = await _elevenLabsService.textToSpeech(
        text,
        languageCode: code,
      );

      if (!mounted) return;

      if (bytes != null) {
        await _audioPlayer.stop();
        await _audioPlayer.play(BytesSource(bytes));
      } else {
        showAppSnackBar(context, 'Audio synthesis unavailable');
      }
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, 'Failed to play audio');
      }
    } finally {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  void _handleAnswer({required bool isMastered}) {
    if (_deck.isEmpty) return;

    final currentTerm = _deck[_currentIndex];
    if (isMastered) {
      _masteredTermIds.add(currentTerm.id);
    } else {
      if (!_trickyTerms.any(
        (t) => t.id == currentTerm.id && t.termWord == currentTerm.termWord,
      )) {
        _trickyTerms.add(currentTerm);
      }
    }

    if (_currentIndex + 1 < _deck.length) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _flipController.reset();
    } else {
      setState(() {
        _sessionDuration = DateTime.now().difference(_sessionStartTime);
        _isSessionFinished = true;
      });
    }
  }

  void _restartWithTrickyTerms() {
    if (_trickyTerms.isEmpty) return;
    setState(() {
      _deck = List.from(_trickyTerms);
      _currentIndex = 0;
      _isFlipped = false;
      _masteredTermIds.clear();
      _trickyTerms.clear();
      _isSessionFinished = false;
      _sessionStartTime = DateTime.now();
    });
    _flipController.reset();
  }

  void _onClose() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(AppRoutes.vocabulary);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _onClose,
          ),
          title: const Text('Loading Practice...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_deck.isEmpty) {
      return _buildEmptyState(context);
    }

    if (_isSessionFinished) {
      return _buildSessionSummary(context);
    }

    return _buildActiveSession(context);
  }

  PreferredSizeWidget _buildAppBar({
    required String title,
    required VoidCallback onClose,
    String? closeTooltip,
  }) {
    return AppBar(
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: closeTooltip,
        onPressed: onClose,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
      ),
      actions: const [
        Padding(padding: EdgeInsets.only(right: 16), child: UserAvatar()),
      ],
    );
  }

  void _confirmQuit() {
    showDialog<bool>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Quit practice session?'),
          content: const Text(
            'Your current session progress will not be saved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Resume'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx, true);
                _onClose();
              },
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              child: const Text('Quit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveSession(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final term = _deck[_currentIndex];
    final progress = (_currentIndex + 1) / _deck.length;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: _buildAppBar(
        title: 'Active Flashcard Session',
        closeTooltip: 'Exit session',
        onClose: _confirmQuit,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            children: [
              _buildSessionHeader(progress, scheme),
              const SizedBox(height: 16),

              // 3D Flippable Card
              Expanded(
                child: GestureDetector(
                  onTap: _toggleFlip,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, _) {
                      final angle = _flipAnimation.value * math.pi;
                      final isUnder = _flipAnimation.value >= 0.5;

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: isUnder
                            ? Transform(
                                transform: Matrix4.identity()..rotateY(math.pi),
                                alignment: Alignment.center,
                                child: PracticeCardBack(
                                  term: term,
                                  isPlayingAudio: _isPlayingAudio,
                                  onSpeakPressed: () =>
                                      _speakCurrentTerm(term.termWord),
                                ),
                              )
                            : PracticeCardFront(
                                term: term,
                                isPlayingAudio: _isPlayingAudio,
                                onSpeakPressed: () =>
                                    _speakCurrentTerm(term.termWord),
                              ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(
                    key: ValueKey<bool>(_isFlipped),
                    child: _isFlipped
                        ? PracticeRevealedControls(
                            onAgain: () => _handleAnswer(isMastered: false),
                            onGotIt: () => _handleAnswer(isMastered: true),
                          )
                        : PracticeRatingControls(
                            onAgain: () => _handleAnswer(isMastered: false),
                            onHard: () => _handleAnswer(isMastered: false),
                            onGotIt: () => _handleAnswer(isMastered: true),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionHeader(double progress, ColorScheme scheme) {
    final label = widget.folder != null
        ? widget.folder!.name.toUpperCase()
        : 'VOCABULARY DRILL';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    backgroundColor: scheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Pill(
              color: scheme.surfaceContainerHigh,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 14,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${_currentIndex + 1} / ${_deck.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Daily Streak +1',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionSummary(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final total = _deck.length;
    final mastered = _masteredTermIds.length;
    final accuracy = total > 0 ? ((mastered / total) * 100).round() : 100;

    final durationString = _sessionDuration.inMinutes > 0
        ? '${_sessionDuration.inMinutes}m ${_sessionDuration.inSeconds % 60}s'
        : '${_sessionDuration.inSeconds}s';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        gradient: RadialGradient(
          center: const Alignment(0, -0.55),
          radius: 1.0,
          colors: [scheme.primary.withValues(alpha: 0.12), Colors.transparent],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(title: 'Session Summary', onClose: _onClose),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SizedBox(
                    width: 88,
                    height: 84,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHigh,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: scheme.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: scheme.primary,
                              size: 38,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'SESSION ACCOMPLISHED',
                    style: text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    accuracy >= 80
                        ? 'Exemplary Focus!'
                        : (accuracy >= 50 ? 'Great Practice!' : 'Keep Going!'),
                    textAlign: TextAlign.center,
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                Center(
                  child: SizedBox(
                    width: 184,
                    height: 184,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: accuracy / 100),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => CustomPaint(
                            size: const Size(184, 184),
                            painter: AccuracyRingPainter(
                              progress: value,
                              track: scheme.surfaceContainerHighest,
                              start: scheme.primary,
                              end: Color.lerp(
                                scheme.primary,
                                Colors.white,
                                0.45,
                              )!,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$accuracy',
                                    style: TextStyle(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w800,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '%',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'ACCURACY',
                              style: text.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.amber,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Streak Extended!',
                              style: text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '19 consecutive days learned',
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Pill(
                        color: scheme.primaryContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          '+100 XP ⚡',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SummaryStatTile(
                              icon: Icons.check_rounded,
                              color: Colors.green,
                              value: '$mastered',
                              label: 'Mastered',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SummaryStatTile(
                              icon: Icons.refresh_rounded,
                              color: Colors.amber.shade700,
                              value: '${_trickyTerms.length}',
                              label: 'To Review',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SummaryMetric(
                            label: 'REVIEWED',
                            value: '$total Terms',
                          ),
                          SummaryMetric(
                            label: 'DURATION',
                            value: durationString,
                          ),
                          SummaryMetric(
                            label: 'XP EARNED',
                            value: '+${mastered * 10} XP',
                            valueColor: Colors.amber.shade700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (_trickyTerms.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TRICKY TERMS IN THIS SET',
                        style: text.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${_trickyTerms.length} items',
                        style: text.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final term in _trickyTerms) TrickyTermRow(term: term),
                ],

                const SizedBox(height: 22),

                if (_trickyTerms.isNotEmpty) ...[
                  GlowBox(
                    color: scheme.primary,
                    radius: 28,
                    child: FilledButton(
                      onPressed: _restartWithTrickyTerms,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: const StadiumBorder(),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh_rounded, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Review Mistakes',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.onPrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '${_trickyTerms.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                FilledButton.tonal(
                  onPressed: _onClose,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    const needed = 5;
    const saved = 2;
    const remaining = needed - saved;
    final percent = ((saved / needed) * 100).round();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: _buildAppBar(
        title: 'Active Flashcard Session',
        onClose: _onClose,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const EmptyDeckIllustration(saved: saved, needed: needed),

              const SizedBox(height: 4),

              Center(
                child: Pill(
                  color: scheme.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: scheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'DECK INCOMPLETE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  'Not enough terms yet',
                  textAlign: TextAlign.center,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text.rich(
                TextSpan(
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                  children: [
                    const TextSpan(text: 'Save at least '),
                    TextSpan(
                      text: '$needed terms',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (widget.folder != null)
                      TextSpan(text: ' into "${widget.folder!.name}"'),
                    const TextSpan(
                      text: ' to practice flashcards.\nYou currently have ',
                    ),
                    TextSpan(
                      text: '$saved saved',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Readiness Milestone',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$saved / $needed TERMS SAVED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (var i = 0; i < needed; i++)
                          Expanded(
                            child: Container(
                              height: 6,
                              margin: EdgeInsets.only(
                                right: i == needed - 1 ? 0 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: i < saved
                                    ? scheme.primary
                                    : scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$remaining more to unlock practice mode',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              GlowBox(
                color: scheme.primary,
                radius: 28,
                child: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.translate),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.translate_rounded),
                  label: const Text(
                    'Translate a Word',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              FilledButton.tonalIcon(
                onPressed: () => context.go(AppRoutes.vocabulary),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.folder_open_rounded),
                label: const Text(
                  'Browse Vocabulary Library',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUICK ADD RECOMMENDED',
                    style: text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.translate),
                    child: Text(
                      'View All',
                      style: text.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final word in const [
                    'Serendipity',
                    'Epiphany',
                    'Luminescence',
                  ])
                    QuickAddChip(
                      label: word,
                      onTap: () => context.go(AppRoutes.translate),
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
