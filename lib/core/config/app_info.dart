/// Static app metadata.
///
/// Keep [version] in sync with `version:` in `pubspec.yaml`. Once the app is
/// distributed via stores, replace this with `package_info_plus` so the value
/// is read from the build itself.
abstract final class AppInfo {
  const AppInfo._();

  /// Semantic version of the app (from pubspec: `1.0.0+1`).
  static const String version = '1.0.0';

  /// Product website.
  static final Uri website = Uri.parse('https://gewerber.de');

  /// Legal pages.
  static final Uri imprint = Uri.parse('https://gewerber.de/imprint');
  static final Uri privacy = Uri.parse('https://gewerber.de/privacy');
}
