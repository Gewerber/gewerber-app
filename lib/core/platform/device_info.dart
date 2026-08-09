import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Platform capabilities that drive UI decisions (e.g. which social
/// identity providers are offered on a given platform).
abstract final class DeviceInfo {
  const DeviceInfo._();

  /// Whether the app runs in a web browser.
  static bool get isWeb => kIsWeb;

  /// Whether the app runs on Android.
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Whether the app runs on iOS.
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Whether the app runs on a desktop OS (Windows/macOS/Linux).
  static bool get isDesktop =>
      !kIsWeb &&
      defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS;
}
