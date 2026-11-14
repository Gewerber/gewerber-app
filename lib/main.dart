import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

import 'package:gewerber_app/bootstrap.dart';
import 'package:gewerber_app/core/config/app_flavor.dart';

/// Production entry point (default target, also built by the Dockerfile).
///
/// No flavor banner is shown (`name` is empty). `SERVER_HOST` defaults to
/// `http://localhost:8080` for plain `flutter run` and is overridden to
/// `https://api.gewerber.de` by the Docker build (`--dart-define`). Auth mode
/// follows the build mode: mock in debug, live in release.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(
    name: AppFlavor.prod.bannerName,
    color: AppFlavor.prod.bannerColor,
    variables: const {
      // `--dart-define=SERVER_HOST=...` (used by Docker/CI) overrides the
      // default; without it the app targets the local backend.
      'serverHost': String.fromEnvironment(
        'SERVER_HOST',
        defaultValue: 'https://api.gewerber.de',
      ),
      'googleClientId': String.fromEnvironment('GOOGLE_CLIENT_ID'),
      'googleIosClientId': String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
      'appleClientId': String.fromEnvironment('APPLE_CLIENT_ID'),
      'appleRedirectUri': String.fromEnvironment('APPLE_REDIRECT_URI'),
      'facebookAppId': String.fromEnvironment('FACEBOOK_APP_ID'),
      'microsoftClientId': String.fromEnvironment('MICROSOFT_CLIENT_ID'),
      'microsoftTenant': String.fromEnvironment(
        'MICROSOFT_TENANT',
        defaultValue: 'common',
      ),
      'authRedirectUri': String.fromEnvironment('AUTH_REDIRECT_URI'),
    },
  );
  await bootstrap();
}
