import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/user.dart';

/// Persists a lightweight snapshot of the authenticated [User].
///
/// The security-sensitive tokens live in the Serverpod session manager; this
/// store only remembers the user's identity so the UI can render it after a
/// session restore without extra network calls.
@LazySingleton(env: [AppEnvironment.authLive])
class SessionStore {
  static const _kId = 'auth.user.id';
  static const _kEmail = 'auth.user.email';
  static const _kDisplayName = 'auth.user.displayName';

  /// Loads the last authenticated user, or `null` when none was stored.
  Future<User?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kId);
    final email = prefs.getString(_kEmail);
    if (id == null || email == null) return null;
    return User(
      id: id,
      email: email,
      displayName: prefs.getString(_kDisplayName),
    );
  }

  /// Persists [user] so it can be restored later.
  Future<void> writeUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kId, user.id);
    await prefs.setString(_kEmail, user.email);
    if (user.displayName != null) {
      await prefs.setString(_kDisplayName, user.displayName!);
    } else {
      await prefs.remove(_kDisplayName);
    }
  }

  /// Clears any stored user.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kId);
    await prefs.remove(_kEmail);
    await prefs.remove(_kDisplayName);
  }
}
