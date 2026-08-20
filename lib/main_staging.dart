import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

import 'package:gewerber_app/bootstrap.dart';
import 'package:gewerber_app/core/config/app_flavor.dart';

/// Staging flavor: test backend, live auth, orange banner.
///
/// Run with: `flutter run -t lib/main_staging.dart -d chrome`
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(
    name: AppFlavor.staging.bannerName,
    color: AppFlavor.staging.bannerColor,
    variables: const {
      // `--dart-define=SERVER_HOST=...` still overrides the default.
      'serverHost': String.fromEnvironment(
        'SERVER_HOST',
        defaultValue: 'https://api.test.gewerber.de',
      ),
      'authMode': 'live',
      'googleClientId': String.fromEnvironment('GOOGLE_CLIENT_ID'),
      'appleClientId': String.fromEnvironment('APPLE_CLIENT_ID'),
      'facebookAppId': String.fromEnvironment('FACEBOOK_APP_ID'),
    },
  );
  await bootstrap();
}
