// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Term _$TermFromJson(Map<String, dynamic> json) => Term(
  id: (json['id'] as num).toInt(),
  termWord: json['termWord'] as String,
  sourceLanguage: json['sourceLanguage'] as String?,
  targetLanguage: json['targetLanguage'] as String?,
  termDefinitions: (json['termDefinitions'] as List<dynamic>)
      .map((e) => TermDefinition.fromJson(e as Map<String, dynamic>))
      .toSet(),
  termExamples: (json['termExamples'] as List<dynamic>)
      .map((e) => Example.fromJson(e as Map<String, dynamic>))
      .toSet(),
  exampleDefinitions: (json['exampleDefinitions'] as List<dynamic>)
      .map((e) => ExampleDefinition.fromJson(e as Map<String, dynamic>))
      .toSet(),
);

Map<String, dynamic> _$TermToJson(Term instance) => <String, dynamic>{
  'id': instance.id,
  'termWord': instance.termWord,
  'sourceLanguage': instance.sourceLanguage,
  'targetLanguage': instance.targetLanguage,
  'termDefinitions': instance.termDefinitions.toList(),
  'termExamples': instance.termExamples.toList(),
  'exampleDefinitions': instance.exampleDefinitions.toList(),
};
