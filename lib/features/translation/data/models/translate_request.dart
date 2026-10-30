import 'package:json_annotation/json_annotation.dart';
import 'package:smart_translator/core/models/language_target.dart';

part 'translate_request.g.dart';

@JsonSerializable()
class TranslateRequest {
  TranslateRequest({
    required this.termWord,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  final String? termWord;
  final LanguageTarget? sourceLanguage;
  final LanguageTarget? targetLanguage;

  factory TranslateRequest.fromJson(Map<String, dynamic> json) =>
      _$TranslateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TranslateRequestToJson(this);
}
