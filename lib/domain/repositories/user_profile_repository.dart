import 'package:gewerber_app/domain/entities/my_identity.dart';
import 'package:gewerber_app/domain/entities/user_profile.dart';

/// Contract for user-profile operations used by the application layer.
abstract interface class UserProfileRepository {
  /// Loads the signed-in user's profile.
  Future<UserProfile> get();

  /// Returns the authenticated caller's own identity: global admin role (if
  /// any) and all business memberships with names.
  Future<MyIdentity> me();

  /// Persists the given display name on the user's profile.
  ///
  /// All other profile attributes stay untouched.
  Future<UserProfile> updateDisplayName(String? displayName);

  /// Exports all data of the signed-in user as a ZIP archive (GDPR Art. 20).
  Future<List<int>> exportMyData();

  /// Permanently deletes the signed-in account.
  ///
  /// The server severs all personal links in retained business data (GDPR
  /// Art. 17); after this call every request for the account fails with
  /// [AccountDeletedException].
  Future<void> deleteAccount();
}
