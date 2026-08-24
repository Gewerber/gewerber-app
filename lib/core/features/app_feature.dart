import 'package:go_router/go_router.dart';

import 'package:gewerber_app/di/injection.dart';

/// Extension point for pluggable application features.
///
/// The open-source app ships with an empty feature set and is fully
/// functional without any external feature. Private distributions
/// (`gewerber-app-commercial`) provide [AppFeature] implementations and pass
/// them to [bootstrap]; their routes are appended to the root router and
/// their [register] hook runs during startup, after [configureDependencies].
abstract class AppFeature {
  const AppFeature();

  /// Unique identifier, also used as the route path prefix recommendation.
  String get name;

  /// Called once during startup; register services in [getIt] here.
  void register() {}

  /// Additional top-level routes mounted after the main shell.
  List<RouteBase> routes() => const [];
}

/// Active feature instances, populated by [bootstrap] before the first frame.
final List<AppFeature> appFeatures = <AppFeature>[];
