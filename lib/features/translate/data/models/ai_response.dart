import 'package:json_annotation/json_annotation.dart';

part 'ai_response.g.dart';

@JsonSerializable()
class AiResponse {
  final String termWord;
  final String exampleSentence;
  final Set<String> termDefinitions;
  final String exampleDefinition;

  new({
    required this.termWord,
    required this.exampleSentence,
    required this.termDefinitions,
    required this.exampleDefinition,
  });

  factory AiResponse.fromJson(Map<String, dynamic> json) =>
      _$AiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AiResponseToJson(this);
}
