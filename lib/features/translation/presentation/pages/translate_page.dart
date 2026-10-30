import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator/core/models/language_target.dart';
import 'package:smart_translator/features/vocabulary/presentation/controllers/vocabulary_cubit.dart';

import '../../../vocabulary/domain/repositories/vocabulary_repository.dart';
import '../../data/models/ai_response.dart';
import '../../domain/repositories/translate_repository.dart';
import '../controllers/translate_cubit.dart';

class TranslatePage extends StatelessWidget {
  const TranslatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              TranslateCubit(context.read<TranslateRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              VocabularyCubit(context.read<VocabularyRepository>()),
        ),
      ],
      child: const _TranslateView(),
    );
  }
}

class _TranslateView extends StatefulWidget {
  const _TranslateView();

  @override
  State<_TranslateView> createState() => _TranslateViewState();
}

class _TranslateViewState extends State<_TranslateView> {
  final TextEditingController _inputController = TextEditingController();
  LanguageTarget _sourceLanguage = LanguageTarget.english;
  LanguageTarget _targetLanguage = LanguageTarget.spanish;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _onTranslatePressed() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<TranslateCubit>().translate(
      _inputController.text,
      _sourceLanguage,
      _targetLanguage,
    );
  }

  void _onAddToVocabularyPressed(AiResponse aiResponse) {
    context.read<VocabularyCubit>().confirmTermSave(aiResponse);
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
  }

  String _formatLangName(LanguageTarget lang) {
    switch (lang) {
      case LanguageTarget.arabic:
        return 'Arabic';
      case LanguageTarget.english:
        return 'English';
      case LanguageTarget.french:
        return 'French';
      case LanguageTarget.germany:
        return 'German';
      case LanguageTarget.italy:
        return 'Italian';
      case LanguageTarget.spanish:
        return 'Spanish';
      case LanguageTarget.russian:
        return 'Russian';
      case LanguageTarget.kurdishSorani:
        return 'Sorani';
      case LanguageTarget.kurdishKurmanji:
        return 'Kurmanji';
      case LanguageTarget.dutch:
        return 'Dutch';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VocabularyCubit, VocabularyState>(
      listener: (context, state) {
        if (state is VocabularyFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is VocabularyLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Term saved to vocabulary successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title & History Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Translate',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.history_rounded,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Find the word. Keep the meaning.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Language Selector Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButtonHideUnderline(
                          child: DropdownButton<LanguageTarget>(
                            value: _sourceLanguage,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            items: LanguageTarget.values.map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(_formatLangName(e)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _sourceLanguage = val);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: _swapLanguages,
                          icon: const Icon(
                            Icons.swap_horiz_rounded,
                            color: Colors.black54,
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<LanguageTarget>(
                            value: _targetLanguage,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            items: LanguageTarget.values.map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(_formatLangName(e)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _targetLanguage = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Source Input Box Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatLangName(_sourceLanguage).toUpperCase()} - SOURCE',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            if (_inputController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _inputController.clear();
                                  setState(() {});
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _inputController,
                          maxLines: 3,
                          onChanged: (_) => setState(() {}),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Please enter a word or sentence'
                              : null,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter word or sentence to translate...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {},
                              icon: const Icon(
                                Icons.mic_none_rounded,
                                color: Colors.black54,
                                size: 20,
                              ),
                            ),
                            Text(
                              '${_inputController.text.length} / 500',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Translate Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _onTranslatePressed,
                      child: const Text(
                        'Translate',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Translation Result Section
                  BlocBuilder<TranslateCubit, TranslateState>(
                    builder: (context, state) {
                      if (state is TranslateLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        );
                      } else if (state is TranslateSuccess) {
                        final res = state.result;
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_formatLangName(_targetLanguage).toUpperCase()} - TRANSLATION',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.volume_up_outlined,
                                        size: 20,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 12),
                                      Icon(
                                        Icons.copy_outlined,
                                        size: 18,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                res.termWord ?? '',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (res.termDefinitions != null &&
                                  res.termDefinitions!.isNotEmpty)
                                Text(
                                  res.termDefinitions!.first,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              if (res.exampleSentence != null &&
                                  res.exampleSentence!.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        res.exampleSentence!,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (res.exampleDefinition != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          res.exampleDefinition!,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Save to Vocabulary Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF5E8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFCE9B2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.bookmark_border_rounded,
                                          size: 18,
                                          color: Color(0xFFD97706),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Save to Vocabulary?',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 26),
                                      child: Text(
                                        '■ Will save locally first',
                                        style: TextStyle(
                                          color: Color(0xFFD97706),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _onAddToVocabularyPressed(res),
                                        child: const Text(
                                          '+ Save term',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (state is TranslateFailure) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Error: ${state.message}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'Enter a word above to see translation',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
