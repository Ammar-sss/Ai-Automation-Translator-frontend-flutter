import 'package:json_annotation/json_annotation.dart';

part 'term_definitions.g.dart';

@JsonSerializable()
class TermDefinitions {
  TermDefinitions({required this.id, required this.definition});

  final int? id;
  final String? definition;

  factory TermDefinitions.fromJson(Map<String, dynamic> json) =>
      _$TermDefinitionsFromJson(json);
  Map<String, dynamic> toJson() => _$TermDefinitionsToJson(this);
}
