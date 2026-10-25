import 'package:json_annotation/json_annotation.dart';

part 'example_definition.g.dart';

@JsonSerializable()
class ExampleDefinition {
  ExampleDefinition({required this.exampleDefinition});

  final String? exampleDefinition;

  factory ExampleDefinition.fromJson(Map<String, dynamic> json) =>
      _$ExampleDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$ExampleDefinitionToJson(this);
}
