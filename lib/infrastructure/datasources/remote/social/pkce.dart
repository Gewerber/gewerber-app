import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// PKCE helpers for the browser-redirect flows (RFC 7636).
abstract final class Pkce {
  /// Generates a cryptographically random code verifier.
  ///
  /// The verifier is the base64url encoding (without padding) of 32 random
  /// bytes, i.e. 43 characters — the lower bound allowed by RFC 7636.
  static String generateCodeVerifier([Random? random]) {
    final rng = random ?? Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return _base64Url(bytes);
  }

  /// Computes the S256 code challenge for [codeVerifier].
  static String codeChallengeS256(String codeVerifier) {
    final digest = sha256.convert(utf8.encode(codeVerifier));
    return _base64Url(digest.bytes);
  }

  /// Generates the `state` value that ties the authorization request to the
  /// callback (and protects against CSRF).
  static String generateState([Random? random]) {
    final rng = random ?? Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return _base64Url(bytes);
  }

  static String _base64Url(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');
}
