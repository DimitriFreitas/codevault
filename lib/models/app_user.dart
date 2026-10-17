import 'model_parsing.dart';

/// A fictional user used by the mocked authentication.
class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.username,
    required this.password,
  });

  final String id;
  final String displayName;
  final String username;
  final String password;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: requireString(json, 'id'),
      displayName: requireString(json, 'name'),
      username: requireString(json, 'username'),
      password: requireString(json, 'password'),
    );
  }
}
