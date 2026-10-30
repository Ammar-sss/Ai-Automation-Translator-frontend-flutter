// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translate_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslateRequest _$TranslateRequestFromJson(Map<String, dynamic> json) =>
    TranslateRequest(
      termWord: json['termWord'] as String?,
      sourceLanguage: $enumDecodeNullable(
        _$LanguageTargetEnumMap,
        json['sourceLanguage'],
      ),
      targetLanguage: $enumDecodeNullable(
        _$LanguageTargetEnumMap,
        json['targetLanguage'],
      ),
    );

Map<String, dynamic> _$TranslateRequestToJson(TranslateRequest instance) =>
    <String, dynamic>{
      'termWord': instance.termWord,
      'sourceLanguage': _$LanguageTargetEnumMap[instance.sourceLanguage],
      'targetLanguage': _$LanguageTargetEnumMap[instance.targetLanguage],
    };

const _$LanguageTargetEnumMap = {
  LanguageTarget.arabic: 'ARABIC',
  LanguageTarget.english: 'ENGLISH',
  LanguageTarget.french: 'FRENCH',
  LanguageTarget.germany: 'GERMANY',
  LanguageTarget.italy: 'ITALIAN',
  LanguageTarget.spanish: 'SPANISH',
  LanguageTarget.russian: 'RUSSIAN',
  LanguageTarget.kurdishKurmanji: 'KURDISH_SORANI',
  LanguageTarget.kurdishSorani: 'KURDISH_KURMANJI',
  LanguageTarget.dutch: 'DUTCH',
};
