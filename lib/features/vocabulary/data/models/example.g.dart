// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Example _$ExampleFromJson(Map<String, dynamic> json) => Example(
  id: (json['id'] as num?)?.toInt(),
  exampleSentence: json['exampleSentence'] as String?,
);

Map<String, dynamic> _$ExampleToJson(Example instance) => <String, dynamic>{
  'id': instance.id,
  'exampleSentence': instance.exampleSentence,
};
