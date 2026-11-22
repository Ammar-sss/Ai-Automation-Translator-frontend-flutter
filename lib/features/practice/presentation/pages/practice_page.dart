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

import '../widgets/practice_action_controls.dart';
import '../widgets/practice_card_back.dart';
import '../widgets/practice_card_front.dart';
import '../widgets/practice_empty_state.dart';
import '../widgets/practice_session_summary.dart';

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
      return PracticeEmptyState(folder: widget.folder, onClose: _onClose);
    }

    if (_isSessionFinished) {
      return PracticeSessionSummary(
        totalTerms: _deck.length,
        masteredCount: _masteredTermIds.length,
        duration: _sessionDuration,
        trickyTerms: _trickyTerms,
        onReviewMistakes: _restartWithTrickyTerms,
        onDone: _onClose,
      );
    }

    return _buildActiveSession(context);
  }

  Widget _buildActiveSession(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final term = _deck[_currentIndex];
    final progress = (_currentIndex + 1) / _deck.length;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Exit session',
          onPressed: () {
            showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
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
              ),
            );
          },
        ),
        title: const Text(
          'Active Flashcard Session',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                'U',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
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
                        Flexible(
                          child: Text(
                            widget.folder != null
                                ? widget.folder!.name.toUpperCase()
                                : 'VOCABULARY DRILL',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelSmall?.copyWith(
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Streak +1',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${_deck.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                                  onSpeak: () =>
                                      _speakCurrentTerm(term.termWord),
                                ),
                              )
                            : PracticeCardFront(
                                term: term,
                                isPlayingAudio: _isPlayingAudio,
                                onSpeak: () => _speakCurrentTerm(term.termWord),
                              ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              PracticeActionControls(
                onAgain: () => _handleAnswer(isMastered: false),
                onHard: () => _handleAnswer(isMastered: false),
                onGotIt: () => _handleAnswer(isMastered: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
