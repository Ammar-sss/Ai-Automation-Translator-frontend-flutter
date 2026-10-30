/// Pure domain entity representing a vocabulary term and its definitions.
class VocabularyTerm {
  const VocabularyTerm({
    this.id,
    required this.word,
    this.definitions = const [],
    this.examples = const [],
    this.exampleDefinitions = const [],
    this.isSynced = false,
  });

  final int? id;
  final String word;
  final List<String> definitions;
  final List<String> examples;
  final List<String> exampleDefinitions;
  final bool isSynced;
}
