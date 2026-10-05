import 'package:go_router/go_router.dart';

/// Whether [router]'s configured route tree can serve [location].
///
/// Features are pluggable: private distributions mount additional routes via
/// `AppFeature.routes()` (see `core/features/app_feature.dart`), so a route
/// that exists in the commercial build may be absent from the OSS shell. This
/// is a pure, side-effect-free tree walk used to decide whether to offer a
/// navigation action (e.g. the free-tier quota paywall's "view plans" button)
/// without attempting a navigation that would land on the error page.
///
/// Absolute paths are reconstructed the way go_router resolves them: a child
/// [GoRoute.path] beginning with `/` is absolute, otherwise it is appended to
/// its parent's path.
bool goRouterHasLocation(GoRouter router, String location) {
  final target = _normalize(location);
  return _treeContains(router.configuration.routes, '', target);
}

bool _treeContains(List<RouteBase> routes, String parentPath, String target) {
  for (final route in routes) {
    final fullPath = route is GoRoute
        ? _resolve(parentPath, route.path)
        : parentPath;
    if (route is GoRoute && fullPath == target) return true;
    if (_treeContains(route.routes, fullPath, target)) return true;
  }
  return false;
}

String _resolve(String parent, String path) {
  if (path.startsWith('/')) return _normalize(path);
  if (parent.isEmpty || parent == '/') return _normalize('/$path');
  return _normalize('$parent/$path');
}

String _normalize(String path) {
  if (path.length > 1 && path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}
