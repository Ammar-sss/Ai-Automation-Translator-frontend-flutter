import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator/features/vocabulary/presentation/controllers/vocabulary_cubit.dart';

import '../../data/repositories/vocabulary_repository.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          VocabularyCubit(context.read<VocabularyRepository>()),
      child: const _VocabularyView(),
    );
  }
}

class _VocabularyView extends StatefulWidget {
  const _VocabularyView();

  @override
  State<_VocabularyView> createState() => _VocabularyViewState();
}

class _VocabularyViewState extends State<_VocabularyView> {
  @override
  void initState() {
    super.initState();
    context.read<VocabularyCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VocabularyCubit, VocabularyState>(
      listener: (context, state) {
        if (state is VocabularyFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is VocabularyLoading || state is VocabularyInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is VocabularyFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<VocabularyCubit>().load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is VocabularyLoaded) {
          return state.terms.isEmpty
              ? SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => context.read<VocabularyCubit>().load(),
                        icon: const Icon(Icons.refresh),
                      ),
                      const Text('No vocabulary terms saved yet.'),
                    ],
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () => context.read<VocabularyCubit>().load(),
                        icon: const Icon(Icons.refresh),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.terms.length,
                          itemBuilder: (context, index) {
                            final term = state.terms[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Word: ${term.termWord ?? ''}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (term.termDefinitions != null &&
                                      term.termDefinitions!.isNotEmpty)
                                    Text(
                                      "Definitions: ${term.termDefinitions!.map((d) => d.definition).join(', ')}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  if (term.termExamples != null &&
                                      term.termExamples!.isNotEmpty)
                                    Text(
                                      "Examples: ${term.termExamples!.map((e) => e.exampleSentence).join(', ')}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  if (term.exampleDefinitions != null &&
                                      term.exampleDefinitions!.isNotEmpty)
                                    Text(
                                      "Example Defs: ${term.exampleDefinitions!.map((e) => e.exampleDefinition).join(', ')}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
        }
        return const SizedBox();
      },
    );
  }
}
