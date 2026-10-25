import 'package:json_annotation/json_annotation.dart';

part 'translate_request.g.dart';

@JsonSerializable()
class TranslateRequest {
  TranslateRequest({required this.termWord});

  final String? termWord;

  factory TranslateRequest.fromJson(Map<String, dynamic> json) =>
      _$TranslateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TranslateRequestToJson(this);
}
