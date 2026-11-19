// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term_definitions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TermDefinition _$TermDefinitionFromJson(Map<String, dynamic> json) =>
    TermDefinition(
      id: (json['id'] as num).toInt(),
      definition: json['definition'] as String,
    );

Map<String, dynamic> _$TermDefinitionToJson(TermDefinition instance) =>
    <String, dynamic>{'id': instance.id, 'definition': instance.definition};
