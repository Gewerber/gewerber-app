import 'package:gewerber_backend_client/gewerber_backend_client.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'package:gewerber_app/core/config/app_config.dart';
import 'package:gewerber_app/core/config/app_environment.dart';

/// Owns the single Serverpod [Client] used across the app.
///
/// The client is wired with the connectivity monitor and a
/// [FlutterAuthSessionManager] so tokens are stored securely, refreshed
/// automatically and restored across restarts. Constructing the client does
/// not touch the network; call [initialize] once at startup.
@LazySingleton(env: [AppEnvironment.authLive])
class ServerpodClientFactory {
  ServerpodClientFactory(this._config) {
    client = Client(_normalizedUrl(_config.serverHost))
      ..connectivityMonitor = FlutterConnectivityMonitor()
      ..authSessionManager = FlutterAuthSessionManager();
  }

  final AppConfig _config;

  late final Client client;

  /// Session manager backing `client.auth`.
  FlutterAuthSessionManager get sessionManager => client.auth;

  /// Restores and validates any persisted session.
  Future<void> initialize() => sessionManager.initialize();

  static String _normalizedUrl(String host) {
    final url = host.trim();
    return url.endsWith('/') ? url : '$url/';
  }
}
