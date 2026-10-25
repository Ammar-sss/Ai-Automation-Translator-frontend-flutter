import 'package:json_annotation/json_annotation.dart';
import 'package:smart_translator/core/models/user.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.user,
    required this.roles,
  });

  final String? token;
  final String? refreshToken;
  final String? tokenType = "Bearer";
  final int? expiresIn;
  final int? refreshExpiresIn;
  final User? user;
  final List<String>? roles;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
