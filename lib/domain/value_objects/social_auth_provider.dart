/// Supported social identity providers.
///
/// The provider is resolved to platform-specific OAuth configuration in the
/// infrastructure layer (see `core/config/app_config.dart`).
///
/// The names match the backend's `SocialAuthProvider` enum, which serializes
/// `google`, `apple`, `facebook` and `microsoft`.
enum SocialAuthProvider {
  google,
  apple,
  facebook,
  microsoft;

  /// Resolves a provider from the wire name used by the backend
  /// (`AuthProvider`), or `null` for values this build does not know.
  ///
  /// Callers pass `authProvider.name` (the generated enum's wire value).
  static SocialAuthProvider? tryFromWire(Object? value) {
    final name = value is String ? value : (value as Enum?)?.name;
    return switch (name) {
      'google' => SocialAuthProvider.google,
      'apple' => SocialAuthProvider.apple,
      'facebook' => SocialAuthProvider.facebook,
      'microsoft' => SocialAuthProvider.microsoft,
      _ => null,
    };
  }
}
