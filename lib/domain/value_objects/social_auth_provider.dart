/// Supported social identity providers.
///
/// The provider is resolved to platform-specific OAuth configuration in the
/// infrastructure layer (see `core/config/app_config.dart`).
///
/// The names match the backend's `SocialAuthProvider` enum, which serializes
/// `google`, `apple`, `facebook` and `microsoft`. The wire → domain mapping is
/// an exhaustive switch over the generated `AuthProvider` enum in
/// `UserProfileRemoteDataSource`, so a new backend provider breaks the build
/// there rather than being silently dropped.
enum SocialAuthProvider { google, apple, facebook, microsoft }
