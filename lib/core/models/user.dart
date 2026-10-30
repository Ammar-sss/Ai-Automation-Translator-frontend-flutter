import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Mirrors `UserDTO` (id, username, email).
@JsonSerializable()
class User {
  const User({this.id, this.username, this.email, this.enabled});

  final int? id;
  final String? username;
  final String? email;
  final bool? enabled;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          enabled == other.enabled;

  @override
  int get hashCode =>
      id.hashCode ^ username.hashCode ^ email.hashCode ^ enabled.hashCode;
}
