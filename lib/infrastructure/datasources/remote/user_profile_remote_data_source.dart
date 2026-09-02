import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/my_identity.dart' as domain;
import 'package:gewerber_app/domain/entities/user_profile.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';

/// Transport-level user-profile calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class UserProfileRemoteDataSource {
  UserProfileRemoteDataSource(this._clientFactory);

  final ServerpodClientFactory _clientFactory;

  sdk.Client get _client => _clientFactory.client;

  /// Loads the signed-in user's profile.
  Future<UserProfile> get() async {
    try {
      final profile = await _client.userProfile.getMyProfile();
      return _fromModel(profile);
    } on sdk.NotFoundException {
      // The backend answers NotFound for every profile request of a deleted
      // account.
      throw const AccountDeletedException();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Returns the authenticated caller's own identity.
  Future<domain.MyIdentity> me() async {
    try {
      final identity = await _client.userProfile.me();
      return _fromIdentityModel(identity);
    } on sdk.NotFoundException {
      throw const AccountDeletedException();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Exports all data of the signed-in user as a ZIP archive (GDPR Art. 20).
  Future<List<int>> exportMyData() async {
    try {
      final byteData = await _client.userProfile.exportMyData();
      return byteData.buffer.asUint8List().toList();
    } on sdk.NotFoundException {
      throw const AccountDeletedException();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Persists [displayName] while keeping every other profile attribute.
  Future<UserProfile> updateDisplayName(String? displayName) async {
    try {
      // `locale` and `themeMode` are required by the protocol; echo the
      // stored values so this call only touches the display name.
      final current = await _client.userProfile.getMyProfile();
      final updated = await _client.userProfile.update(
        sdk.UpdateUserProfileRequest(
          displayName: displayName,
          locale: current.locale,
          timeZone: current.timeZone,
          themeMode: current.themeMode,
        ),
      );
      return _fromModel(updated);
    } on sdk.NotFoundException {
      throw const AccountDeletedException();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Permanently deletes the signed-in account on the server.
  ///
  /// A `NotFoundException` is treated as success: repeating the call after
  /// deletion throws NotFound, but from the caller's perspective the account
  /// is gone either way.
  Future<void> deleteAccount() async {
    try {
      await _client.userProfile.deleteMyAccount();
    } on sdk.NotFoundException {
      // Already deleted — nothing left to do.
      return;
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  UserProfile _fromModel(sdk.UserProfile model) {
    return UserProfile(
      userId: model.userId.toString(),
      displayName: model.displayName,
    );
  }

  domain.MyIdentity _fromIdentityModel(sdk.MyIdentity model) {
    return domain.MyIdentity(
      userId: model.userId.toString(),
      globalRole: model.globalRole != null
          ? domain.AdminRole.fromName(model.globalRole!.toJson())
          : null,
      memberships: model.memberships
          .map(
            (m) => domain.MyMembershipInfo(
              businessId: m.businessId,
              businessName: m.businessName,
              role: domain.MembershipRole.fromName(m.role.toJson()),
            ),
          )
          .toList(),
    );
  }
}
