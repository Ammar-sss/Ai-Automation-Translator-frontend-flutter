// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_definitions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExampleDefinition _$ExampleDefinitionFromJson(Map<String, dynamic> json) =>
    ExampleDefinition(
      id: (json['id'] as num).toInt(),
      exampleDefinition: json['exampleDefinition'] as String,
    );

Map<String, dynamic> _$ExampleDefinitionToJson(ExampleDefinition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exampleDefinition': instance.exampleDefinition,
    };
