// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term_definitions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TermDefinitions _$TermDefinitionsFromJson(Map<String, dynamic> json) =>
    TermDefinitions(
      id: (json['id'] as num?)?.toInt(),
      definition: json['definition'] as String?,
    );

Map<String, dynamic> _$TermDefinitionsToJson(TermDefinitions instance) =>
    <String, dynamic>{'id': instance.id, 'definition': instance.definition};
