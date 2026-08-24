import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:gewerber_app/core/features/app_feature.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';

/// Shared startup routine used by every flavor entry point
/// (`lib/main.dart`, `lib/main_dev.dart`, `lib/main_staging.dart`).
///
/// Each entry point must initialize [FlavorConfig] before calling this, so
/// [AppEnvironment] and [AppConfig] can resolve the active flavor.
///
/// [features] are pluggable feature modules (see [AppFeature]); the
/// open-source build passes none. Private distributions append theirs; each
/// feature's routes become available and its [AppFeature.register] hook runs
/// before the first frame.
Future<void> bootstrap({List<AppFeature> features = const []}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // German is the primary product market; the settings cubit keeps this in
  // sync with the user's chosen app language afterwards.
  Intl.defaultLocale = defaultFormatLocale;
  configureDependencies();
  for (final feature in features) {
    feature.register();
  }
  appFeatures.addAll(features);
  runApp(const GewerberApp());
}
