
import 'package:flutter/material.dart';

import '../../../user/presentation/widgets/profile_drawer.dart';
import '../../data/models/ai_response.dart';
import '../widgets/translation_result_bottom_sheet.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePage();
}

class _TranslatePage extends State<TranslatePage>{
  final TextEditingController _inputController = TextEditingController();
  bool _isOnline = true; // Toggle between Online and Offline modes
  bool _showOfflineBanner = true;
  String _sourceLanguage = 'English';
  String _targetLanguage = 'Spanish';

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF11131D);
    const containerColor = Color(0xFF1E1F2A);
    const cardBorderColor = Color(0xFF282935);
    const primaryOrange = Color(0xFFFF5A2C);
    const successGreen = Color(0xFF4AE183);
    const offlineOrange = Color(0xFFFF8A65);
    const textMuted = Color(0xFFAB8981);
    const textSlate = Color(0xFFE4BEB5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF282935),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.translate_rounded,
                  color: primaryOrange,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AI translator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'HOME',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Toggleable Online / Offline Status Chip
          GestureDetector(
            onTap: () => setState(() => _isOnline = !_isOnline),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF282935),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isOnline
                      ? successGreen.withValues(alpha: 0.5)
                      : offlineOrange.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isOnline ? successGreen : offlineOrange,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: _isOnline ? successGreen : offlineOrange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => ProfileDrawer.open(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB5A1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF601300),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offline Alert Banner (Only shown in offline mode when not dismissed)
              if (!_isOnline && _showOfflineBanner) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF33200A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF664014)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Color(0xFFFFB020),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Offline, translating needs a connection',
                          style: TextStyle(
                            color: Color(0xFFFFB020),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showOfflineBanner = false),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFFFFB020),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // User Greeting Row
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryOrange, width: 1.5),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF282935),
                      child: Text(
                        'L',
                        style: TextStyle(
                          color: primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isOnline)
                          const Text(
                            'WELCOME BACK',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        const Text(
                          'Hello, Linh',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isOnline)
                          const Text(
                            'Offline Mode Active',
                            style: TextStyle(color: textMuted, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282935),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isOnline ? successGreen : offlineOrange,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: _isOnline ? successGreen : offlineOrange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main Translator Input Card (Switches UI according to Online / Offline mode)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cardBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Language Selectors Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF282935),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _sourceLanguage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: textMuted,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _swapLanguages,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF282935),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: primaryOrange,
                              size: 18,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF282935),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _targetLanguage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: textMuted,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Text Input Field
                    TextFormField(
                      controller: _inputController,
                      maxLines: 4,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: _isOnline
                            ? 'Type word or phrase to translate...'
                            : 'Type word or phrase...',
                        hintStyle: const TextStyle(
                          color: textMuted,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (!_isOnline) ...[
                      // Offline Cached Info Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: successGreen,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Cached dictionary available',
                                style: TextStyle(
                                  color: offlineOrange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_inputController.text.length} / 250',
                            style: const TextStyle(
                              color: textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Bottom Action Row
                    if (_isOnline)
                    // ONLINE MODE: Mic icon, Paste icon + Large Floating Orange Submit Button (→)
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.mic_none_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.content_paste_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                          const Spacer(),
                          // Large Orange Submit Button (→)
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: primaryOrange,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryOrange.withValues(alpha: 0.5),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                final text = _inputController.text.trim();
                                TranslationResultBottomSheet.show(
                                  context,
                                  aiResponse: AiResponse(
                                    termWord: text.isNotEmpty
                                        ? text
                                        : 'Serendipity',
                                    exampleSentence:
                                    '"Finding this quaint bookstore in the gentle rain was pure serendipity."',
                                    termDefinitions: {
                                      'The occurrence and development of events by chance in a happy, delightful, or beneficial way.',
                                    },
                                    exampleDefinition:
                                    '"Encontrar esta pintoresca librería bajo la suave lluvia fue pura serendipia."',
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    else
                    // OFFLINE MODE: Actions bar
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.content_paste_rounded,
                              color: textMuted,
                              size: 20,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _inputController.clear();
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.backspace_outlined,
                              color: textMuted,
                              size: 20,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF52281E),
                                foregroundColor: offlineOrange,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {},
                              icon: const Icon(
                                Icons.wifi_off_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'Translate',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_isOnline) ...[
                // ONLINE MODE: Recent Pill Chips Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.history_rounded, color: textMuted, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'RECENT',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Clear',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Horizontal Recent Chips with Phonetics
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _RecentChip(
                        term: 'Ephemeral',
                        phonetics: '/ɪˈfem.ər.əl/',
                      ),
                      SizedBox(width: 8),
                      _RecentChip(term: 'Ikigai', phonetics: '/i.ki.ɡai/'),
                      SizedBox(width: 8),
                      _RecentChip(term: 'Petrichor', phonetics: '/pe.tri.kor/'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ONLINE MODE: 2-Column Metrics Cards (Daily Streak 14 days + Mastered 128 words)
                Row(
                  children: [
                    // Daily Streak Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'DAILY STREAK',
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Color(0xFFFFB020),
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: const [
                                Text(
                                  '14',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'days',
                                  style: TextStyle(
                                    color: textSlate,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Mastered Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'MASTERED',
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: successGreen,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: const [
                                Text(
                                  '128',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'words',
                                  style: TextStyle(
                                    color: textSlate,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // OFFLINE MODE: Recent Cached Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: Color(0xFFFFB020),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Recent Cached',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'LOCAL DB',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Horizontal Recent Cached Terms List
                SizedBox(
                  height: 88,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _CachedTermCard(
                        langPair: 'EN → ES',
                        term: 'Ephemeral',
                        translation: 'Efímero',
                      ),
                      SizedBox(width: 10),
                      _CachedTermCard(
                        langPair: 'JA → EN',
                        term: 'Ikigai',
                        translation: 'Life Purpose',
                      ),
                      SizedBox(width: 10),
                      _CachedTermCard(
                        langPair: 'EN → ES',
                        term: 'Petrichor',
                        translation: 'Petricor',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Offline Pack Status Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF282935),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.done_all_rounded,
                          color: offlineOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Spanish Offline Pack',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '42 MB • Fully installed',
                              style: TextStyle(color: textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Ready',
                        style: TextStyle(
                          color: successGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({required this.term, required this.phonetics});

  final String term;
  final String phonetics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF282935)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            term,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            phonetics,
            style: const TextStyle(color: Color(0xFFAB8981), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CachedTermCard extends StatelessWidget {
  const _CachedTermCard({
    required this.langPair,
    required this.term,
    required this.translation,
  });

  final String langPair;
  final String term;
  final String translation;

  @override
  Widget build(BuildContext context) {
    const containerColor = Color(0xFF1E1F2A);
    const cardBorderColor = Color(0xFF282935);
    const textMuted = Color(0xFFAB8981);

    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                langPair,
                style: const TextStyle(
                  color: Color(0xFF4AE183),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF4AE183),
                size: 14,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                term,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                translation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}