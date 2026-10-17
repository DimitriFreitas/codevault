import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../state/app_scope.dart';

/// Ensures the current user is authenticated.
///
/// Returns `true` when already logged in. Otherwise pushes the login screen and
/// returns whether the login succeeded. Use this to gate authenticated actions.
Future<bool> ensureAuthenticated(BuildContext context, {String? reason}) async {
  if (AppScope.read(context).isAuthenticated) {
    return true;
  }
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => LoginScreen(reason: reason)),
  );
  return result ?? false;
}
