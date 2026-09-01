/// Shared, framework-free constants used across the application.
library;

/// Assets bundled with the app.
abstract final class AppAssets {
  const AppAssets._();

  /// Official Gewerber symbol mark (SVG).
  static const String gewerberSymbol = 'assets/images/gewerber-symbol.svg';
}

/// Product-wide key/value identifiers.
abstract final class AppConstants {
  const AppConstants._();

  /// Minimum password length enforced by the backend policy.
  static const int minPasswordLength = 8;

  /// Length of the email verification code used during registration
  /// and password reset. Must match the backend generator
  /// (`_verificationCodeLength` in `server.dart`).
  static const int verificationCodeLength = 8;

  /// Time (in seconds) before a verification code can be requested again.
  static const int resendCodeCooldownSeconds = 30;
}
