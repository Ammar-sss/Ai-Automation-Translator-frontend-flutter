/// Pure domain entity representing an authenticated user.
class UserEntity {
  const UserEntity({
    this.id,
    this.username,
    this.email,
    this.enabled,
  });

  final int? id;
  final String? username;
  final String? email;
  final bool? enabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ email.hashCode;
}
