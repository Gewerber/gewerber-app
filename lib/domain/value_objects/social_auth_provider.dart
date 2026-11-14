/// Supported social identity providers.
///
/// The provider is resolved to platform-specific OAuth configuration in the
/// infrastructure layer (see `core/config/app_config.dart`).
///
/// The names match the backend's `SocialAuthProvider` enum, which serializes
/// `google`, `apple`, `facebook` and `microsoft`.
enum SocialAuthProvider { google, apple, facebook, microsoft }
