import 'package:gewerber_backend_client/gewerber_backend_client.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/user_preferences.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';
import 'package:gewerber_app/infrastructure/mappers/user_preferences_mapper.dart';

/// Transport-level user profile calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class UserPreferencesRemoteDataSource {
  UserPreferencesRemoteDataSource(this._clientFactory, this._mapper);

  final ServerpodClientFactory _clientFactory;
  final UserPreferencesMapper _mapper;

  Client get _client => _clientFactory.client;

  /// Loads the signed-in user's profile preferences.
  Future<UserPreferences?> getMyPreferences() async {
    try {
      final profile = await _client.userProfile.getMyProfile();
      return _mapper.fromProfile(profile);
    } on ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Persists the given preferences on the user's profile.
  Future<void> update(UserPreferences preferences) async {
    try {
      await _client.userProfile.update(
        sdkUpdateUserProfileRequest(preferences),
      );
    } on ServerpodClientException {
      throw const NetworkException();
    }
  }

  UpdateUserProfileRequest sdkUpdateUserProfileRequest(
    UserPreferences preferences,
  ) {
    return UpdateUserProfileRequest(
      locale: _mapper.toProtocolLocale(preferences.locale),
      themeMode: _mapper.toProtocolTheme(preferences.theme),
    );
  }
}
