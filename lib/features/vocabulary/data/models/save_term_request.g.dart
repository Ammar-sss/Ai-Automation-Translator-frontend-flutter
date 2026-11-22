// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_term_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveTermRequest _$SaveTermRequestFromJson(Map<String, dynamic> json) =>
    SaveTermRequest(
      termWord: json['termWord'] as String,
      sourceLanguage: $enumDecode(
        _$TranslationLanguageEnumMap,
        json['sourceLanguage'],
      ),
      targetLanguage: $enumDecode(
        _$TranslationLanguageEnumMap,
        json['targetLanguage'],
      ),
      exampleSentence: json['exampleSentence'] as String,
      termDefinitions: (json['termDefinitions'] as List<dynamic>)
          .map((e) => e as String)
          .toSet(),
      exampleDefinition: json['exampleDefinition'] as String,
    );

Map<String, dynamic> _$SaveTermRequestToJson(SaveTermRequest instance) =>
    <String, dynamic>{
      'termWord': instance.termWord,
      'sourceLanguage': _$TranslationLanguageEnumMap[instance.sourceLanguage]!,
      'targetLanguage': _$TranslationLanguageEnumMap[instance.targetLanguage]!,
      'exampleSentence': instance.exampleSentence,
      'termDefinitions': instance.termDefinitions.toList(),
      'exampleDefinition': instance.exampleDefinition,
    };

const _$TranslationLanguageEnumMap = {
  TranslationLanguage.arabic: 'ARABIC',
  TranslationLanguage.english: 'ENGLISH',
  TranslationLanguage.french: 'FRENCH',
  TranslationLanguage.germany: 'GERMANY',
  TranslationLanguage.italy: 'ITALIAN',
  TranslationLanguage.spanish: 'SPANISH',
  TranslationLanguage.russian: 'RUSSIAN',
  TranslationLanguage.kurdishSorani: 'KURDISH_SORANI',
  TranslationLanguage.kurdishKurmanji: 'KURDISH_KURMANJI',
  TranslationLanguage.dutch: 'DUTCH',
};
