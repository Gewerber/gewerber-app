import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/infrastructure/datasources/remote/social/pkce.dart';

void main() {
  group('Pkce.codeChallengeS256', () {
    test('matches the RFC 7636 appendix B test vector', () {
      expect(
        Pkce.codeChallengeS256('dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk'),
        'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM',
      );
    });

    test('is the unpadded base64url encoding of the SHA-256 digest', () {
      final verifier = 'a' * 43;
      final expected = base64Url
          .encode(sha256.convert(utf8.encode(verifier)).bytes)
          .replaceAll('=', '');

      expect(Pkce.codeChallengeS256(verifier), expected);
    });

    test('produces 43 URL-safe characters without padding', () {
      final challenge = Pkce.codeChallengeS256('x' * 64);

      expect(challenge.length, 43);
      expect(challenge, isNot(contains('=')));
      expect(challenge, isNot(contains('+')));
      expect(challenge, isNot(contains('/')));
    });
  });

  group('Pkce.generateCodeVerifier', () {
    test('stays within the RFC 7636 length bounds (43-128)', () {
      for (var i = 0; i < 50; i++) {
        final verifier = Pkce.generateCodeVerifier();
        expect(verifier.length, greaterThanOrEqualTo(43));
        expect(verifier.length, lessThanOrEqualTo(128));
      }
    });

    test('uses the unreserved base64url alphabet only', () {
      final verifier = Pkce.generateCodeVerifier();

      expect(verifier, matches(RegExp(r'^[A-Za-z0-9\-_]+$')));
    });

    test('is random across calls', () {
      final verifiers = <String>{
        for (var i = 0; i < 20; i++) Pkce.generateCodeVerifier(),
      };

      expect(verifiers.length, 20);
    });
  });

  group('Pkce.generateState', () {
    test('produces a non-empty URL-safe value', () {
      final state = Pkce.generateState();

      expect(state, isNotEmpty);
      expect(state, matches(RegExp(r'^[A-Za-z0-9\-_]+$')));
    });

    test('is random across calls', () {
      final states = <String>{
        for (var i = 0; i < 20; i++) Pkce.generateState(),
      };

      expect(states.length, 20);
    });
  });
}
