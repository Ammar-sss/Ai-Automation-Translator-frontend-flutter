// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiResponse _$AiResponseFromJson(Map<String, dynamic> json) => AiResponse(
  termWord: json['termWord'] as String?,
  exampleSentence: json['exampleSentence'] as String?,
  termDefinitions: (json['termDefinitions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toSet(),
  exampleDefinition: json['exampleDefinition'] as String?,
);

Map<String, dynamic> _$AiResponseToJson(AiResponse instance) =>
    <String, dynamic>{
      'termWord': instance.termWord,
      'exampleSentence': instance.exampleSentence,
      'termDefinitions': instance.termDefinitions?.toList(),
      'exampleDefinition': instance.exampleDefinition,
    };
