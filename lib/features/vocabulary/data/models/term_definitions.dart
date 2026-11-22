import 'package:json_annotation/json_annotation.dart';

part 'term_definitions.g.dart';

@JsonSerializable()
class TermDefinition {
  final int id;
  final String definition;

  new({required this.id, required this.definition});

  factory TermDefinition.fromJson(Map<String, dynamic> json) =>
      _$TermDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$TermDefinitionToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermDefinition &&
          runtimeType == other.runtimeType &&
          definition.trim().toLowerCase() ==
              other.definition.trim().toLowerCase();

  @override
  int get hashCode => definition.trim().toLowerCase().hashCode;
}
