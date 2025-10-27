class UserProfile {
  final String name;
  final String email;
  final String? avatarUrl;

  const UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}
