import 'package:flutter/material.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';

/// Shared startup routine used by every flavor entry point
/// (`lib/main.dart`, `lib/main_dev.dart`, `lib/main_staging.dart`).
///
/// Each entry point must initialize [FlavorConfig] before calling this, so
/// [AppEnvironment] and [AppConfig] can resolve the active flavor.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const GewerberApp());
}
