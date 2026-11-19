// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translate_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslateRequest _$TranslateRequestFromJson(Map<String, dynamic> json) =>
    TranslateRequest(
      termWord: json['termWord'] as String,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
    );

Map<String, dynamic> _$TranslateRequestToJson(TranslateRequest instance) =>
    <String, dynamic>{
      'termWord': instance.termWord,
      'sourceLanguage': instance.sourceLanguage,
      'targetLanguage': instance.targetLanguage,
    };
