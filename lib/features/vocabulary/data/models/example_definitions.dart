import 'package:json_annotation/json_annotation.dart';

part 'example_definitions.g.dart';

@JsonSerializable()
class ExampleDefinition {
  final int id;
  final String exampleDefinition;

  new({required this.id, required this.exampleDefinition});

  factory ExampleDefinition.fromJson(Map<String, dynamic> json) =>
      _$ExampleDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$ExampleDefinitionToJson(this);
}
