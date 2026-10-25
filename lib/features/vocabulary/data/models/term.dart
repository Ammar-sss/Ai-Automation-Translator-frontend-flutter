import 'package:json_annotation/json_annotation.dart';
import 'package:smart_translator/features/vocabulary/data/models/example.dart';
import 'package:smart_translator/features/vocabulary/data/models/example_definition.dart';
import 'package:smart_translator/features/vocabulary/data/models/term_definitions.dart';

part 'term.g.dart';

@JsonSerializable()
class Term {
  final int? id;
  final String? termWord;
  final Set<TermDefinitions>? termDefinitions;
  final Set<Example>? termExamples;
  final Set<ExampleDefinition>? exampleDefinitions;

  Term({
    required this.id,
    required this.termWord,
    required this.termDefinitions,
    required this.termExamples,
    required this.exampleDefinitions,
  });

  factory Term.fromJson(Map<String, dynamic> json) => _$TermFromJson(json);
  Map<String, dynamic> toJson() => _$TermToJson(this);
}
