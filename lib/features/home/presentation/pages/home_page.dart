import 'package:flutter/material.dart';
import '../../../user/presentation/widgets/profile_drawer.dart';

// ---------------------------------------------------------------------------
// Design tokens (same palette as MainWrapperPage)
// ---------------------------------------------------------------------------
class _C {
  static const bg = Color(0xFF11131D);
  static const card = Color(0xFF191B26);
  static const cardAlt = Color(0xFF1F2230);
  static const border = Color(0xFF2A2D3B);
  static const orange = Color(0xFFFF5A2C);
  static const green = Color(0xFF3DDC84);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFA9ABB8);
  static const textMuted = Color(0xFF7C7F8F);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  bool _wordSaved = false;

  // Placeholder data: replace with your real state / repositories.
  static const _recent = <_RecentItem>[
    _RecentItem('Ephemeral', 'Efímero', 'Spanish', '10m ago'),
    _RecentItem('Petrichor', 'Petricor', 'Spanish', '2h ago'),
    _RecentItem('Ikigai', 'Razón de ser', 'Spanish', 'Yesterday'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _translate() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    // TODO: call your translation use case / bloc here.
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              const _TopBar(),
              const SizedBox(height: 16),
              const _Greeting(),
              const SizedBox(height: 16),
              _TranslateInputCard(
                controller: _controller,
                onSubmit: _translate,
              ),
              const SizedBox(height: 16),
              _DailyFocusCard(
                learned: 12,
                goal: 20,
                onContinue: () {
                  // TODO: navigate to the practice session.
                },
              ),
              const SizedBox(height: 16),
              _WordOfTheDayCard(
                saved: _wordSaved,
                onSpeak: () {
                  // TODO: text-to-speech for the word.
                },
                onSave: () => setState(() => _wordSaved = !_wordSaved),
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Recent Translations',
                actionLabel: 'View all',
                onAction: () {
                  // TODO: open the full history.
                },
              ),
              const SizedBox(height: 10),
              for (final item in _recent) ...[
                _RecentTile(item: item),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _C.orange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.translate, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI translator',
              style: TextStyle(
                color: _C.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'HOME',
              style: TextStyle(
                color: _C.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const Spacer(),
        const _StatusChip(label: 'Online', color: _C.green),
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => ProfileDrawer.open(context),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _C.cardAlt,
              shape: BoxShape.circle,
              border: Border.all(color: _C.border),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: _C.textSecondary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _C.cardAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _C.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Greeting row
// ---------------------------------------------------------------------------
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: _C.cardAlt,
              // TODO: swap for NetworkImage / user avatar.
              child: Icon(Icons.person, color: _C.textSecondary),
            ),
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _C.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: _C.bg, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Linh',
                style: TextStyle(
                  color: _C.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Wednesday, 24 Oct',
                style: TextStyle(color: _C.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _C.cardAlt,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.border),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: _C.orange, size: 16),
              SizedBox(width: 4),
              Text(
                '7 Days',
                style: TextStyle(
                  color: _C.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Translate input card
// ---------------------------------------------------------------------------
class _TranslateInputCard extends StatelessWidget {
  const _TranslateInputCard({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              const _LangPill(code: 'EN'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.swap_horiz_rounded,
                    color: _C.textMuted, size: 16),
              ),
              const _LangPill(code: 'ES'),
              const Spacer(),
              const Icon(Icons.auto_awesome, color: _C.orange, size: 13),
              const SizedBox(width: 4),
              const Text(
                'Auto-Detect',
                style: TextStyle(
                  color: _C.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSubmit(),
                  textInputAction: TextInputAction.done,
                  cursorColor: _C.orange,
                  style: const TextStyle(
                    color: _C.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Type a word or phrase to translate',
                    hintStyle: TextStyle(color: _C.textMuted, fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: start speech-to-text.
                },
                icon: const Icon(Icons.mic_rounded,
                    color: _C.orange, size: 20),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
              Material(
                color: _C.orange,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onSubmit,
                  child: const SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  const _LangPill({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _C.cardAlt,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _C.border),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: _C.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Daily focus card
// ---------------------------------------------------------------------------
class _DailyFocusCard extends StatelessWidget {
  const _DailyFocusCard({
    required this.learned,
    required this.goal,
    required this.onContinue,
  });

  final int learned;
  final int goal;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final progress = (learned / goal).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAILY HABIT',
            style: TextStyle(
              color: _C.orange,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  "Today's Focus",
                  style: TextStyle(
                    color: _C.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$learned',
                style: const TextStyle(
                  color: _C.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' / $goal words',
                style: const TextStyle(
                  color: _C.textMuted,
                  fontSize: 12,
                  height: 1.9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: _C.cardAlt,
              valueColor: const AlwaysStoppedAnimation(_C.orange),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percent% completed',
                style: const TextStyle(
                  color: _C.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${goal - learned} left for milestone',
                style: const TextStyle(color: _C.textMuted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: _C.green, size: 16),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Spaced repetition active',
                  style: TextStyle(
                    color: _C.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onContinue,
                style: TextButton.styleFrom(
                  backgroundColor: _C.cardAlt,
                  foregroundColor: _C.textPrimary,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: _C.border),
                  ),
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Word of the day
// ---------------------------------------------------------------------------
class _WordOfTheDayCard extends StatelessWidget {
  const _WordOfTheDayCard({
    required this.saved,
    required this.onSpeak,
    required this.onSave,
  });

  final bool saved;
  final VoidCallback onSpeak;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Tag(
                label: 'WORD OF THE DAY',
                background: Color(0x33FF5A2C),
                foreground: _C.orange,
              ),
              const SizedBox(width: 8),
              const _Tag(
                label: 'NOUN',
                background: _C.cardAlt,
                foreground: _C.textSecondary,
              ),
              const Spacer(),
              InkWell(
                customBorder: const CircleBorder(),
                onTap: onSpeak,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0x33FF5A2C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volume_up_rounded,
                      color: _C.orange, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Serendipity',
                style: TextStyle(
                  color: _C.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  '/ˌser.ənˈdɪp.ə.ti/',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _C.textMuted,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'The occurrence and development of events by chance in a happy or beneficial way.',
            style: TextStyle(
              color: _C.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.border),
            ),
            child: const Text(
              '"Finding this charming bookshop tucked in the alley was pure serendipity."',
              style: TextStyle(
                color: _C.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.workspace_premium_outlined,
                  color: _C.orange, size: 15),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Advanced vocabulary (C1)',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _C.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onSave,
                style: TextButton.styleFrom(
                  backgroundColor: _C.cardAlt,
                  foregroundColor: saved ? _C.orange : _C.textPrimary,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: _C.border),
                  ),
                ),
                icon: Icon(
                  saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  size: 15,
                ),
                label: Text(
                  saved ? 'Saved' : 'Save to Vocab',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent translations
// ---------------------------------------------------------------------------
class _RecentItem {
  const _RecentItem(this.source, this.translated, this.language, this.when);

  final String source;
  final String translated;
  final String language;
  final String when;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _C.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          behavior: HitTestBehavior.opaque,
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: _C.orange,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.item});

  final _RecentItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _C.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // TODO: open translation detail.
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _C.cardAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.translate,
                    color: _C.textSecondary, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.source,
                      style: const TextStyle(
                        color: _C.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.translated} • ${item.language}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _C.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.when,
                style: const TextStyle(color: _C.textMuted, fontSize: 10),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: _C.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared card container
// ---------------------------------------------------------------------------
class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: child,
    );
  }
}