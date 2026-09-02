import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/my_identity.dart';
import 'package:gewerber_app/domain/entities/user_profile.dart';
import 'package:gewerber_app/domain/repositories/user_profile_repository.dart';

/// In-memory [UserProfileRepository] backing the demo experience and the
/// widget tests. Data lives for the app session only.
@LazySingleton(as: UserProfileRepository, env: [AppEnvironment.authMock])
class MockUserProfileRepository implements UserProfileRepository {
  UserProfile _profile = const UserProfile(userId: 'mock-user');
  bool _deleted = false;

  /// Whether the account has been deleted in this session (test assertions).
  bool get isDeleted => _deleted;

  /// Resets the stored profile (used by tests to isolate scenarios).
  void reset() {
    _profile = const UserProfile(userId: 'mock-user');
    _deleted = false;
  }

  @override
  Future<UserProfile> get() async {
    if (_deleted) throw const AccountDeletedException();
    return _profile;
  }

  @override
  Future<MyIdentity> me() async {
    if (_deleted) throw const AccountDeletedException();
    return const MyIdentity(
      userId: 'mock-user',
      memberships: [],
    );
  }

  @override
  Future<UserProfile> updateDisplayName(String? displayName) async {
    if (_deleted) throw const AccountDeletedException();
    _profile = UserProfile(userId: _profile.userId, displayName: displayName);
    return _profile;
  }

  @override
  Future<List<int>> exportMyData() async {
    if (_deleted) throw const AccountDeletedException();
    return [];
  }

  @override
  Future<void> deleteAccount() async {
    // Mirrors the backend semantics: business data is retained, but every
    // subsequent profile request fails.
    _deleted = true;
  }
}
