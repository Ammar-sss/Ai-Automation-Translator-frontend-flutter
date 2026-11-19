import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/core/util/translation_language.dart';
import 'package:smart_translator_test/features/translate/data/models/translate_request.dart';
import 'package:smart_translator_test/features/translate/presentation/controller/translate_cubit.dart';
import 'package:smart_translator_test/features/translate/presentation/widgets/emptyhint.dart';
import 'package:smart_translator_test/features/translate/presentation/widgets/input_field.dart';
import 'package:smart_translator_test/features/translate/presentation/widgets/language_bar.dart';
import 'package:smart_translator_test/features/translate/presentation/widgets/result_card.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/vocabulary_cubit.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final TextEditingController _termController = TextEditingController();

  TranslationLanguage sourceLang = TranslationLanguage.english;
  TranslationLanguage targetLang = TranslationLanguage.arabic;

  /// Debounce guard: prevents duplicate submits within 500ms.
  Timer? _debounceTimer;

  /// Only the save button listens to this, so saving never rebuilds the page.
  final ValueNotifier<bool> _isSaving = ValueNotifier(false);

  @override
  void dispose() {
    _termController.dispose();
    _debounceTimer?.cancel();
    _isSaving.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    setState(() {
      final temp = sourceLang;
      sourceLang = targetLang;
      targetLang = temp;
    });
  }

  void _submit() {
    final text = _termController.text.trim();
    if (text.isEmpty) return;

    if (_debounceTimer?.isActive ?? false) return;
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {});

    FocusScope.of(context).unfocus();
    _isSaving.value = false;

    context.read<TranslateCubit>().translate(
      TranslateRequest(
        termWord: text,
        sourceLanguage: sourceLang.backendValue,
        targetLanguage: targetLang.backendValue,
      ),
    );
  }

  void _saveToVocabulary(TranslateLoaded state) {
    if (_isSaving.value) return;
    _isSaving.value = true;
    context.read<VocabularyCubit>().confirmTermSave(state.aiResponse);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocListener(
        listeners: [
          BlocListener<TranslateCubit, TranslateState>(
            listener: (context, state) {
              if (state is TranslateFailure) {
                _showSnack(context, state.message, isError: true);
              }
            },
          ),
          BlocListener<VocabularyCubit, VocabularyState>(
            listener: (context, state) {
              if (state is TermSavedSuccess) {
                _isSaving.value = false;
                _showSnack(context, 'Saved to vocabulary');
              } else if (state is VocabularyFailure) {
                _isSaving.value = false;
              }
            },
          ),
        ],
        child: Padding(
          padding: context.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LanguageBar(
                source: sourceLang,
                target: targetLang,
                onSourceChanged: (v) {
                  if (v != null) setState(() => sourceLang = v);
                },
                onTargetChanged: (v) {
                  if (v != null) setState(() => targetLang = v);
                },
                onSwap: _swapLanguages,
              ),
              SizedBox(height: context.hp(2)),
              InputField(controller: _termController, onSubmit: _submit),
              SizedBox(height: context.hp(1.5)),

              // Only the button + result area rebuild on state changes.
              Expanded(
                child: BlocBuilder<TranslateCubit, TranslateState>(
                  buildWhen: (previous, current) =>
                      previous.runtimeType != current.runtimeType,
                  builder: (context, state) {
                    final isLoading = state is TranslateLoading;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                context.defaultRadius * 1.5,
                              ),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: context.sp(20),
                                  width: context.sp(20),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Text(
                                  'Translate',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        SizedBox(height: context.hp(2)),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: state is TranslateLoaded
                                ? ResultCard(
                                    key: ValueKey(state.aiResponse.termWord),
                                    state: state,
                                    isSaving: _isSaving,
                                    onSave: () => _saveToVocabulary(state),
                                  )
                                : const EmptyHint(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: TextStyle(
              color: isError
                  ? scheme.onErrorContainer
                  : scheme.onInverseSurface,
            ),
          ),
          backgroundColor: isError
              ? scheme.errorContainer
              : scheme.inverseSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.defaultRadius),
          ),
        ),
      );
  }
}
