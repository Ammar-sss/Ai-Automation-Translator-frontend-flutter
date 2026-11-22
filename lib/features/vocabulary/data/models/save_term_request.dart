import 'package:json_annotation/json_annotation.dart';
import 'package:smart_translator_test/core/util/translation_language.dart';

part 'save_term_request.g.dart';

@JsonSerializable()
class SaveTermRequest {
  final String termWord;
  final TranslationLanguage sourceLanguage;
  final TranslationLanguage targetLanguage;
  final String exampleSentence;
  final Set<String> termDefinitions;
  final String exampleDefinition;

  SaveTermRequest({
    required this.termWord,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.exampleSentence,
    required this.termDefinitions,
    required this.exampleDefinition,
  });

  factory SaveTermRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveTermRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SaveTermRequestToJson(this);
}
