import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/core/util/translation_language.dart';
import 'package:smart_translator_test/features/translate/data/models/ai_response.dart';
import 'package:smart_translator_test/features/translate/data/models/translate_request.dart';
import 'package:smart_translator_test/features/translate/presentation/controller/translate_cubit.dart';
import 'package:smart_translator_test/features/translate/presentation/widgets/emptyhint.dart';
import 'package:smart_translator_test/features/translate/presentation/widgets/input_field.dart';
import 'package:smart_translator_test/features/translate/presentation/widgets/language_bar.dart';
import 'package:smart_translator_test/features/translate/presentation/widgets/result_card.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/folder_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/widgets/folder_picker_sheet.dart';

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

  Future<void> _saveToVocabulary(TranslateLoaded state) async {
    if (_isSaving.value) return;

    final aiResponse = state.aiResponse;

    // 1. Ask user where to save the term
    final selectedFolder = await FolderPickerSheet.show(
      context,
      termWord: aiResponse.termWord,
    );

    if (selectedFolder == null || !mounted) return;

    _isSaving.value = true;
    final folderCubit = context.read<FolderCubit>();

    try {
      // 2. Save directly to local database
      final localTerm = _mapAiResponseToTerm(aiResponse);

      await AppDatabase.instance.saveTermToFolder(
        term: localTerm,
        folderId: selectedFolder.id,
      );

      folderCubit.loadFolders();

      if (mounted) {
        _isSaving.value = false;
        _showSnack(context, 'Saved to "${selectedFolder.name}"');
      }
    } catch (e) {
      if (mounted) {
        _isSaving.value = false;
        _showSnack(
          context,
          'Failed to save: ${e.toString().replaceAll("Exception: ", "")}',
          isError: true,
        );
      }
    }
  }

  Term _mapAiResponseToTerm(AiResponse ai) {
    return Term(
      id: 0,
      termWord: ai.termWord,
      termDefinitions: ai.termDefinitions
          .map((d) => TermDefinition(id: 0, definition: d))
          .toSet(),
      termExamples: ai.exampleSentence.isNotEmpty
          ? {Example(id: 0, exampleSentence: ai.exampleSentence)}
          : {},
      exampleDefinitions: ai.exampleDefinition.isNotEmpty
          ? {ExampleDefinition(id: 0, exampleDefinition: ai.exampleDefinition)}
          : {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<TranslateCubit, TranslateState>(
        listener: (context, state) {
          if (state is TranslateFailure) {
            _showSnack(context, state.message, isError: true);
          }
        },
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
                  builder: (context, state) {
                    final isLoading = state is TranslateLoading;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          onPressed: isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: isLoading
                              ? SizedBox(
                                  height: context.sp(20),
                                  width: context.sp(20),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome_rounded),
                          label: Text(
                            isLoading ? 'Translating…' : 'Translate',
                            style: const TextStyle(
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
                                : EmptyHint(
                                    onSelectPrompt: (prompt) {
                                      _termController.text = prompt;
                                      _submit();
                                    },
                                  ),
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
