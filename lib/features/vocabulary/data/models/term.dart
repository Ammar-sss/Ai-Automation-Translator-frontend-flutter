import 'package:json_annotation/json_annotation.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term_definitions.dart';

part 'term.g.dart';

@JsonSerializable()
class Term {
  final int id;
  final String termWord;
  final String? sourceLanguage;
  final String? targetLanguage;
  final Set<TermDefinition> termDefinitions;
  final Set<Example> termExamples;
  final Set<ExampleDefinition> exampleDefinitions;

  Term({
    required this.id,
    required this.termWord,
    this.sourceLanguage,
    this.targetLanguage,
    required this.termDefinitions,
    required this.termExamples,
    required this.exampleDefinitions,
  });

  factory Term.fromJson(Map<String, dynamic> json) => _$TermFromJson(json);
  Map<String, dynamic> toJson() => _$TermToJson(this);
}
