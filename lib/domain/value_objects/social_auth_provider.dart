/// Supported social identity providers.
///
/// The provider is resolved to platform-specific OAuth configuration in the
/// infrastructure layer (see `core/config/app_config.dart`).
enum SocialAuthProvider { google, apple, facebook }
