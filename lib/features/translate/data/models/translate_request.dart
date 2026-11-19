
import 'package:json_annotation/json_annotation.dart';

part 'translate_request.g.dart';

@JsonSerializable()
class TranslateRequest {

  final String termWord;
  final String sourceLanguage;
  final String targetLanguage;

  new({required this.termWord, required this.sourceLanguage, required this.targetLanguage});

  factory TranslateRequest.fromJson(Map<String, dynamic> json) => _$TranslateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TranslateRequestToJson(this);

}
