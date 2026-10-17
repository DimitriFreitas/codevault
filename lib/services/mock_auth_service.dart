import '../models/app_user.dart';

/// Mocked authentication against the fictional users loaded from JSON.
///
/// There is no password hashing, token, or external provider: credentials are
/// compared in plain text against the in-memory user list.
class MockAuthService {
  const MockAuthService();

  /// Returns the matching [AppUser], or `null` when credentials are invalid.
  AppUser? authenticate(
    List<AppUser> users,
    String username,
    String password,
  ) {
    final normalized = username.trim().toLowerCase();
    for (final user in users) {
      if (user.username.toLowerCase() == normalized && user.password == password) {
        return user;
      }
    }
    return null;
  }
}
