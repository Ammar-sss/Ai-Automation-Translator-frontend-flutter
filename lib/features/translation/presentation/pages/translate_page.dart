import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator/features/vocabulary/presentation/controllers/vocabulary_cubit.dart';

import '../../../vocabulary/data/repositories/vocabulary_repository.dart';
import '../../data/models/ai_response.dart';
import '../../data/repositories/translate_repository.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _onTranslatePressed() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<TranslateCubit>().translate(_inputController.text);
  }

  void _onAddToVocabularyPressed(AiResponse aiResponse) {
    context.read<VocabularyCubit>().confirmTermSave(aiResponse);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VocabularyCubit, VocabularyState>(
      listener: (context, state) {
        if (state is VocabularyFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is VocabularyLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Term added to vocabulary")),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Expanded(
                  child: Column(
                    children: [
                      const Text("Enter a word or sentence"),
                      TextFormField(controller: _inputController),
                      ElevatedButton(
                        onPressed: _onTranslatePressed,
                        child: const Text("Translate"),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<TranslateCubit, TranslateState>(
                  builder: (context, state) {
                    if (state is TranslateLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TranslateSuccess) {
                      return Center(
                        child: Column(
                          children: [
                            const Text(
                              "word translated successfully",
                              style: TextStyle(color: Colors.greenAccent),
                            ),
                            Text("term: ${state.result.termWord}"),
                            Text(
                              "term Definitions: ${state.result.termDefinitions}",
                            ),
                            Text("example: ${state.result.exampleSentence}"),
                            Text(
                              "example definition: ${state.result.exampleDefinition}",
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _onAddToVocabularyPressed(state.result),
                              child: const Text("add to vocabulary"),
                            ),
                          ],
                        ),
                      );
                    } else if (state is TranslateFailure) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else {
                      return const Center(child: Text("enter a word"));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
