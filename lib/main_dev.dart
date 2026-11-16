import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

import 'package:gewerber_app/bootstrap.dart';
import 'package:gewerber_app/core/config/app_flavor.dart';

/// Development flavor: local backend, in-memory mock auth, red banner.
///
/// Run with: `flutter run -t lib/main_dev.dart -d chrome`
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(
    name: AppFlavor.dev.bannerName,
    color: AppFlavor.dev.bannerColor,
    variables: const {
      // `--dart-define=SERVER_HOST=...` still overrides the default.
      'serverHost': String.fromEnvironment(
        'SERVER_HOST',
        defaultValue: 'http://localhost:8080',
      ),
      'authMode': 'mock',
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
