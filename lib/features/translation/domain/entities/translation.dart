/// Pure domain entity representing a translation result.
class Translation {
  const Translation({
    this.termWord,
    this.exampleSentence,
    this.termDefinitions = const {},
    this.exampleDefinition,
  });

  final String? termWord;
  final String? exampleSentence;
  final Set<String> termDefinitions;
  final String? exampleDefinition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Translation &&
          runtimeType == other.runtimeType &&
          termWord == other.termWord &&
          exampleSentence == other.exampleSentence &&
          exampleDefinition == other.exampleDefinition;

  @override
  int get hashCode =>
      termWord.hashCode ^ exampleSentence.hashCode ^ exampleDefinition.hashCode;
}
