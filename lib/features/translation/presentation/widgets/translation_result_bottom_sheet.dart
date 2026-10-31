import 'package:flutter/material.dart';
import 'package:smart_translator/features/translation/data/models/ai_response.dart';

class TranslationResultBottomSheet extends StatefulWidget {
  const TranslationResultBottomSheet({
    super.key,
    required this.aiResponse,
    this.onSave,
  });

  final AiResponse aiResponse;
  final VoidCallback? onSave;

  static void show(
    BuildContext context, {
    required AiResponse aiResponse,
    VoidCallback? onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          TranslationResultBottomSheet(aiResponse: aiResponse, onSave: onSave),
    );
  }

  @override
  State<TranslationResultBottomSheet> createState() =>
      _TranslationResultBottomSheetState();
}

class _TranslationResultBottomSheetState
    extends State<TranslationResultBottomSheet> {
  bool _isSaved = false;

  void _handleSave() {
    setState(() {
      _isSaved = true;
    });
    widget.onSave?.call();
  }

  @override
  Widget build(BuildContext context) {
    const sheetBackgroundColor = Color(0xFF191A24);
    const cardColor = Color(0xFF22232F);
    const borderColor = Color(0xFF2D2E3C);
    const primaryOrange = Color(0xFFFF5A2C);
    const successGreen = Color(0xFF4AE183);
    const pendingGold = Color(0xFFFFB020);
    const textMuted = Color(0xFFAB8981);
    const textSlate = Color(0xFFE4BEB5);

    final res = widget.aiResponse;
    final term = (res.termWord != null && res.termWord!.isNotEmpty)
        ? res.termWord!
        : 'fat cat';
    final exampleEn =
        (res.exampleSentence != null && res.exampleSentence!.isNotEmpty)
        ? res.exampleSentence!
        : '"The workers complained about the greed of the fat cat."';
    final exampleEs =
        (res.exampleDefinition != null && res.exampleDefinition!.isNotEmpty)
        ? res.exampleDefinition!
        : 'Los trabajadores se quejaron de la codicia del pez gordo (del magnate adinerado).';

    // Parse list of definitions or fallback to sample definitions
    final definitions =
        (res.termDefinitions != null && res.termDefinitions!.isNotEmpty)
        ? res.termDefinitions!.toList()
        : [
            'A wealthy and powerful person, especially a businessman or politician.',
            'Someone who receives a disproportionately large financial reward.',
          ];

    return Container(
      decoration: const BoxDecoration(
        color: sheetBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle Bar
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF383948),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Saved State Toast Banner (Shown when saved)
            if (_isSaved) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2A22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: successGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: successGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.black,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Saved to terms',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF332A18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: pendingGold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.hourglass_top_rounded,
                            color: pendingGold,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Pending sync',
                            style: TextStyle(
                              color: pendingGold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Top Header (Language Tag + Close Button / Filled Bookmark)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _isSaved ? 'ENGLISH' : 'EN',
                        style: TextStyle(
                          color: _isSaved ? textMuted : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: primaryOrange,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isSaved ? 'SPANISH' : 'ES',
                        style: const TextStyle(
                          color: primaryOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (_isSaved)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryOrange.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_rounded,
                          color: primaryOrange,
                          size: 18,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Headword, Part of Speech & Phonetics
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            term,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Idiom / noun',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "/,fæt 'kæt/",
                        style: TextStyle(color: textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor),
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: primaryOrange,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Example Card ("EXAMPLE" / "CONTEXT EXAMPLE")
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.format_quote_rounded,
                        color: primaryOrange,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'EXAMPLE',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exampleEn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Term Definitions Section ("TERM DEFINITIONS")
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.menu_book_rounded,
                            color: primaryOrange,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'TERM DEFINITIONS',
                            style: TextStyle(
                              color: primaryOrange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${definitions.length} senses',
                        style: const TextStyle(color: textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Numbered Definitions List
                  ...List.generate(definitions.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF381F18),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: primaryOrange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              definitions[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Example Definition Section ("EXAMPLE DEFINITION")
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.g_translate_rounded,
                        color: successGreen,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'EXAMPLE DEFINITION',
                        style: TextStyle(
                          color: successGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exampleEs,
                    style: const TextStyle(
                      color: textSlate,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Button (Unsaved vs Saved State)
            if (!_isSaved)
              // UNSAVED STATE: Orange Button "Save to my terms"
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    shadowColor: primaryOrange.withValues(alpha: 0.45),
                  ),
                  onPressed: _handleSave,
                  icon: const Icon(Icons.bookmark_border_rounded, size: 20),
                  label: const Text(
                    'Save to my terms',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              // SAVED STATE: Green Button "✓ Saved to terms" + Subtitle
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: successGreen.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: successGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.black,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Saved to terms',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF332A18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: pendingGold.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Text(
                            'Queued',
                            style: TextStyle(
                              color: pendingGold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.sd_card_rounded, color: textMuted, size: 12),
                      SizedBox(width: 6),
                      Text(
                        'Saved on this device first, syncs when online',
                        style: TextStyle(color: textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
