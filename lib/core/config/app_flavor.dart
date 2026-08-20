import 'package:flutter/material.dart';

/// Build flavors of the Gewerber app.
///
/// Each flavor is selected through its own entry point
/// (`lib/main.dart` for prod, `lib/main_dev.dart`, `lib/main_staging.dart`)
/// and materialized at startup via `FlavorConfig` (see
/// `package:flutter_flavor`).
enum AppFlavor {
  dev,
  staging,
  prod;

  /// Name shown on the [FlavorBanner]; empty hides the banner (production).
  String get bannerName => switch (this) {
    AppFlavor.dev => 'DEV',
    AppFlavor.staging => 'STAGING',
    AppFlavor.prod => '',
  };

  /// Banner background color, kept readable on both light and dark themes.
  Color get bannerColor => switch (this) {
    AppFlavor.dev => Colors.red,
    AppFlavor.staging => Colors.orange,
    AppFlavor.prod => Colors.transparent,
  };
}
