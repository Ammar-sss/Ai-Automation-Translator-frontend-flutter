
import 'package:json_annotation/json_annotation.dart';

part 'update_user_profile.g.dart';

@JsonSerializable()
class UpdateUserProfile {

  final String username;

  new({required this.username});

  factory UpdateUserProfile.fromJson(Map<String, dynamic> json) => _$UpdateUserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserProfileToJson(this);
}