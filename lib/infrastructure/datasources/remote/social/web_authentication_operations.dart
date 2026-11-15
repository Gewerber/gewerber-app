import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

/// The subset of `flutter_web_auth_2` used by the browser-redirect flows.
///
/// Injected so tests can drive the flow without opening a browser. Shared by
/// every provider that uses the OAuth 2.0 authorization-code flow (Google,
/// Microsoft), so both flows speak to the provider through the same seam.
abstract interface class WebAuthenticationOperations {
  /// Opens [url] and resolves with the callback URL the provider redirected to.
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    String? httpsHost,
    String? httpsPath,
  });
}

/// Default [WebAuthenticationOperations] backed by `flutter_web_auth_2`.
class FlutterWebAuth2Operations implements WebAuthenticationOperations {
  const FlutterWebAuth2Operations();

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    String? httpsHost,
    String? httpsPath,
  }) {
    return FlutterWebAuth2.authenticate(
      url: url,
      callbackUrlScheme: callbackUrlScheme,
      options: FlutterWebAuth2Options(
        httpsHost: httpsHost,
        httpsPath: httpsPath,
      ),
    );
  }
}
