import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/apple_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/facebook_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/google_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/microsoft_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/social_auth_flow.dart';

void main() {
  group('GoogleSocialAuthFlow', () {
    test('maps the SDK account to a GoogleCredential', () async {
      final operations = _FakeGoogleOperations(
        result: const GoogleSignInResult(
          idToken: 'google-id-token',
          accessToken: 'google-access-token',
        ),
      );
      final flow = GoogleSocialAuthFlow(
        clientId: 'web-client',
        iosClientId: 'ios-client',
        operations: operations,
        isWeb: false,
        platform: TargetPlatform.android,
      );

      final credential = await flow.authenticate();

      expect(credential, isA<GoogleCredential>());
      final google = credential as GoogleCredential;
      expect(google.idToken, 'google-id-token');
      expect(google.accessToken, 'google-access-token');
    });

    test('passes serverClientId on Android', () async {
      final operations = _FakeGoogleOperations(
        result: const GoogleSignInResult(idToken: 'id'),
      );
      await GoogleSocialAuthFlow(
        clientId: 'web-client',
        iosClientId: 'ios-client',
        operations: operations,
        isWeb: false,
        platform: TargetPlatform.android,
      ).authenticate();

      expect(operations.initializeServerClientId, 'web-client');
      expect(operations.initializeClientId, isNull);
    });

    test('passes the iOS client id on iOS and the server id on web', () async {
      final ios = _FakeGoogleOperations(
        result: const GoogleSignInResult(idToken: 'id'),
      );
      await GoogleSocialAuthFlow(
        clientId: 'web-client',
        iosClientId: 'ios-client',
        operations: ios,
        isWeb: false,
        platform: TargetPlatform.iOS,
      ).authenticate();
      expect(ios.initializeClientId, 'ios-client');
      expect(ios.initializeServerClientId, 'web-client');

      final web = _FakeGoogleOperations(
        result: const GoogleSignInResult(idToken: 'id'),
      );
      await GoogleSocialAuthFlow(
        clientId: 'web-client',
        iosClientId: 'ios-client',
        operations: web,
        isWeb: true,
        platform: TargetPlatform.android,
      ).authenticate();
      expect(web.initializeClientId, 'web-client');
      expect(web.initializeServerClientId, isNull);
    });

    test('is not configured when the client id is missing', () {
      final flow = GoogleSocialAuthFlow(
        clientId: '',
        iosClientId: '',
        operations: _FakeGoogleOperations(
          result: const GoogleSignInResult(idToken: 'id'),
        ),
        isWeb: true,
        platform: TargetPlatform.android,
      );

      expect(flow.isConfigured, isFalse);
    });

    test('is not configured on Windows', () {
      final flow = GoogleSocialAuthFlow(
        clientId: 'web-client',
        iosClientId: 'ios-client',
        operations: _FakeGoogleOperations(
          result: const GoogleSignInResult(idToken: 'id'),
        ),
        isWeb: false,
        platform: TargetPlatform.windows,
      );

      expect(flow.isConfigured, isFalse);
    });

    test('maps cancellation to SocialAuthCancelledException', () async {
      final flow = GoogleSocialAuthFlow(
        clientId: 'web-client',
        iosClientId: 'ios-client',
        operations: _FakeGoogleOperations(
          error: const GoogleSignInException(
            code: GoogleSignInExceptionCode.canceled,
          ),
        ),
        isWeb: true,
        platform: TargetPlatform.android,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(isA<SocialAuthCancelledException>()),
      );
    });

    test('maps provider errors to SocialAuthFailureException', () async {
      final flow = GoogleSocialAuthFlow(
        clientId: 'web-client',
        iosClientId: 'ios-client',
        operations: _FakeGoogleOperations(
          error: const GoogleSignInException(
            code: GoogleSignInExceptionCode.unknownError,
            description: 'boom',
          ),
        ),
        isWeb: true,
        platform: TargetPlatform.android,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(
          isA<SocialAuthFailureException>().having(
            (e) => e.message,
            'message',
            'boom',
          ),
        ),
      );
    });

    test('rejects an empty id token', () async {
      final flow = GoogleSocialAuthFlow(
        clientId: 'web-client',
        iosClientId: 'ios-client',
        operations: _FakeGoogleOperations(
          result: const GoogleSignInResult(idToken: ''),
        ),
        isWeb: true,
        platform: TargetPlatform.android,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(isA<SocialAuthFailureException>()),
      );
    });

    test('refuses an unsupported platform', () async {
      final flow = GoogleSocialAuthFlow(
        clientId: 'web-client',
        iosClientId: 'ios-client',
        operations: _FakeGoogleOperations(
          result: const GoogleSignInResult(idToken: 'id'),
        ),
        isWeb: false,
        platform: TargetPlatform.linux,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(isA<SocialAuthNotConfiguredException>()),
      );
    });
  });

  group('AppleSocialAuthFlow', () {
    test('maps the native credential', () async {
      final operations = _FakeAppleOperations(
        result: const AppleSignInResult(
          identityToken: 'apple-id-token',
          authorizationCode: 'apple-code',
          givenName: 'Ada',
          familyName: 'Lovelace',
        ),
      );
      final flow = AppleSocialAuthFlow(
        clientId: 'service-id',
        redirectUri: 'https://app.gewerber.de/auth/callback',
        operations: operations,
        isWeb: false,
        platform: TargetPlatform.iOS,
      );

      final credential = await flow.authenticate();

      expect(credential, isA<AppleCredential>());
      final apple = credential as AppleCredential;
      expect(apple.identityToken, 'apple-id-token');
      expect(apple.authorizationCode, 'apple-code');
      expect(apple.isNativeApplePlatformSignIn, isTrue);
      expect(apple.firstName, 'Ada');
      expect(apple.lastName, 'Lovelace');
    });

    test('passes the web options only on web', () async {
      final web = _FakeAppleOperations(
        result: const AppleSignInResult(
          identityToken: 'apple-id-token',
          authorizationCode: 'apple-code',
        ),
      );
      await AppleSocialAuthFlow(
        clientId: 'service-id',
        redirectUri: 'https://app.gewerber.de/auth/callback',
        operations: web,
        isWeb: true,
        platform: TargetPlatform.android,
      ).authenticate();
      expect(web.receivedWebOptions, isNotNull);
      expect(web.receivedWebOptions!.clientId, 'service-id');

      final native = _FakeAppleOperations(
        result: const AppleSignInResult(
          identityToken: 'apple-id-token',
          authorizationCode: 'apple-code',
        ),
      );
      await AppleSocialAuthFlow(
        clientId: 'service-id',
        redirectUri: 'https://app.gewerber.de/auth/callback',
        operations: native,
        isWeb: false,
        platform: TargetPlatform.iOS,
      ).authenticate();
      expect(native.receivedWebOptions, isNull);
    });

    test('is not configured without a client id or redirect uri', () {
      expect(
        AppleSocialAuthFlow(
          clientId: '',
          redirectUri: 'https://app.gewerber.de/auth/callback',
          operations: _FakeAppleOperations(
            result: const AppleSignInResult(
              identityToken: 'id',
              authorizationCode: 'code',
            ),
          ),
          isWeb: true,
          platform: TargetPlatform.android,
        ).isConfigured,
        isFalse,
      );

      expect(
        AppleSocialAuthFlow(
          clientId: 'service-id',
          redirectUri: '',
          operations: _FakeAppleOperations(
            result: const AppleSignInResult(
              identityToken: 'id',
              authorizationCode: 'code',
            ),
          ),
          isWeb: true,
          platform: TargetPlatform.android,
        ).isConfigured,
        isFalse,
      );
    });

    test('maps cancellation to SocialAuthCancelledException', () async {
      final flow = AppleSocialAuthFlow(
        clientId: 'service-id',
        redirectUri: 'https://app.gewerber.de/auth/callback',
        operations: _FakeAppleOperations(
          error: const SignInWithAppleAuthorizationException(
            code: AuthorizationErrorCode.canceled,
            message: 'cancelled',
          ),
        ),
        isWeb: true,
        platform: TargetPlatform.android,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(isA<SocialAuthCancelledException>()),
      );
    });

    test('maps other errors to SocialAuthFailureException', () async {
      final flow = AppleSocialAuthFlow(
        clientId: 'service-id',
        redirectUri: 'https://app.gewerber.de/auth/callback',
        operations: _FakeAppleOperations(
          error: const SignInWithAppleAuthorizationException(
            code: AuthorizationErrorCode.failed,
            message: 'nope',
          ),
        ),
        isWeb: true,
        platform: TargetPlatform.android,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(
          isA<SocialAuthFailureException>().having(
            (e) => e.message,
            'message',
            'nope',
          ),
        ),
      );
    });

    test('rejects a missing identity token', () async {
      final flow = AppleSocialAuthFlow(
        clientId: 'service-id',
        redirectUri: 'https://app.gewerber.de/auth/callback',
        operations: _FakeAppleOperations(
          result: const AppleSignInResult(
            identityToken: null,
            authorizationCode: 'apple-code',
          ),
        ),
        isWeb: true,
        platform: TargetPlatform.android,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(isA<SocialAuthFailureException>()),
      );
    });
  });

  group('FacebookSocialAuthFlow', () {
    test('initialises the web SDK and maps the token', () async {
      final operations = _FakeFacebookOperations(
        result: _loginResult(LoginStatus.success, 'fb-token'),
      );
      final flow = FacebookSocialAuthFlow(
        appId: 'fb-app-id',
        operations: operations,
        isWeb: true,
        platform: TargetPlatform.android,
      );

      final credential = await flow.authenticate();

      expect(credential, isA<FacebookCredential>());
      expect((credential as FacebookCredential).accessToken, 'fb-token');
      expect(operations.initializeCalls, 1);
      expect(operations.lastInitializedAppId, 'fb-app-id');
      expect(operations.lastInitializedVersion, 'v21.0');
    });

    test('skips the web initialisation on mobile', () async {
      final operations = _FakeFacebookOperations(
        result: _loginResult(LoginStatus.success, 'fb-token'),
      );
      await FacebookSocialAuthFlow(
        appId: 'fb-app-id',
        operations: operations,
        isWeb: false,
        platform: TargetPlatform.iOS,
      ).authenticate();

      expect(operations.initializeCalls, 0);
      expect(operations.lastLoginWasWeb, isFalse);
    });

    test('maps a cancelled login to SocialAuthCancelledException', () async {
      final flow = FacebookSocialAuthFlow(
        appId: 'fb-app-id',
        operations: _FakeFacebookOperations(
          result: _loginResult(LoginStatus.cancelled, null),
        ),
        isWeb: true,
        platform: TargetPlatform.android,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(isA<SocialAuthCancelledException>()),
      );
    });

    test('maps a failed login to SocialAuthFailureException', () async {
      final flow = FacebookSocialAuthFlow(
        appId: 'fb-app-id',
        operations: _FakeFacebookOperations(
          result: _loginResult(LoginStatus.failed, null, message: 'nope'),
        ),
        isWeb: false,
        platform: TargetPlatform.android,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(
          isA<SocialAuthFailureException>().having(
            (e) => e.message,
            'message',
            'nope',
          ),
        ),
      );
    });

    test('is not configured without an app id or on macOS', () {
      final operations = _FakeFacebookOperations(
        result: _loginResult(LoginStatus.success, 'fb-token'),
      );

      expect(
        FacebookSocialAuthFlow(
          appId: '',
          operations: operations,
          isWeb: true,
          platform: TargetPlatform.android,
        ).isConfigured,
        isFalse,
      );
      expect(
        FacebookSocialAuthFlow(
          appId: 'fb-app-id',
          operations: operations,
          isWeb: false,
          platform: TargetPlatform.macOS,
        ).isConfigured,
        isFalse,
      );
    });
  });

  group('MicrosoftSocialAuthFlow', () {
    test('builds a PKCE authorize URL and maps the code', () async {
      final operations = _FakeWebAuthOperations(
        callbackUrl: 'https://app.gewerber.de/auth/callback',
      );
      final flow = MicrosoftSocialAuthFlow(
        clientId: 'ms-client',
        redirectUri: 'https://app.gewerber.de/auth/callback',
        tenant: 'contoso',
        operations: operations,
        isWeb: true,
      );

      final credential = await flow.authenticate();

      expect(credential, isA<MicrosoftCredential>());
      final microsoft = credential as MicrosoftCredential;
      expect(microsoft.code, 'auth-code');
      expect(microsoft.redirectUri, 'https://app.gewerber.de/auth/callback');
      expect(microsoft.isWebPlatform, isTrue);
      expect(microsoft.codeVerifier, isNotEmpty);

      final authorize = Uri.parse(operations.lastUrl!);
      expect(authorize.host, 'login.microsoftonline.com');
      expect(authorize.path, '/contoso/oauth2/v2.0/authorize');
      final query = authorize.queryParameters;
      expect(query['client_id'], 'ms-client');
      expect(query['response_type'], 'code');
      expect(query['response_mode'], 'query');
      expect(query['scope'], 'openid profile email offline_access');
      expect(query['code_challenge_method'], 'S256');
      expect(query['code_challenge'], isNotEmpty);
      expect(query['code_challenge'], isNot(microsoft.codeVerifier));
      expect(query['state'], isNotEmpty);
      expect(query['redirect_uri'], 'https://app.gewerber.de/auth/callback');
      expect(operations.lastCallbackUrlScheme, 'https');
      expect(operations.lastHttpsHost, 'app.gewerber.de');
    });

    test('records isWebPlatform=false on a native platform', () async {
      final operations = _FakeWebAuthOperations(
        callbackUrl: 'https://app.gewerber.de/auth/callback',
      );
      final credential = await MicrosoftSocialAuthFlow(
        clientId: 'ms-client',
        redirectUri: 'https://app.gewerber.de/auth/callback',
        operations: operations,
        isWeb: false,
      ).authenticate();

      expect((credential as MicrosoftCredential).isWebPlatform, isFalse);
    });

    test('rejects a state mismatch', () async {
      final operations = _FakeWebAuthOperations(
        callbackUrl:
            'https://app.gewerber.de/auth/callback'
            '?code=auth-code&state=not-the-state',
      );
      final flow = MicrosoftSocialAuthFlow(
        clientId: 'ms-client',
        redirectUri: 'https://app.gewerber.de/auth/callback',
        operations: operations,
        isWeb: true,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(
          isA<SocialAuthFailureException>().having(
            (e) => e.message,
            'message',
            contains('unexpected state'),
          ),
        ),
      );
    });

    test('maps access_denied to SocialAuthCancelledException', () async {
      final operations = _FakeWebAuthOperations(
        callbackUrl:
            'https://app.gewerber.de/auth/callback'
            '?error=access_denied',
      );
      final flow = MicrosoftSocialAuthFlow(
        clientId: 'ms-client',
        redirectUri: 'https://app.gewerber.de/auth/callback',
        operations: operations,
        isWeb: true,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(isA<SocialAuthCancelledException>()),
      );
    });

    test(
      'maps a platform cancellation to SocialAuthCancelledException',
      () async {
        final flow = MicrosoftSocialAuthFlow(
          clientId: 'ms-client',
          redirectUri: 'https://app.gewerber.de/auth/callback',
          operations: _FakeWebAuthOperations(
            error: PlatformException(
              code: 'CANCELED',
              message: 'User canceled login',
            ),
          ),
          isWeb: false,
        );

        await expectLater(
          flow.authenticate(),
          throwsA(isA<SocialAuthCancelledException>()),
        );
      },
    );

    test('maps other platform errors to SocialAuthFailureException', () async {
      final flow = MicrosoftSocialAuthFlow(
        clientId: 'ms-client',
        redirectUri: 'https://app.gewerber.de/auth/callback',
        operations: _FakeWebAuthOperations(
          error: PlatformException(code: 'error', message: 'nope'),
        ),
        isWeb: false,
      );

      await expectLater(
        flow.authenticate(),
        throwsA(
          isA<SocialAuthFailureException>().having(
            (e) => e.message,
            'message',
            'nope',
          ),
        ),
      );
    });

    test('is not configured without a client id or redirect uri', () {
      final operations = _FakeWebAuthOperations(
        callbackUrl: 'https://app.gewerber.de/auth/callback',
      );

      expect(
        MicrosoftSocialAuthFlow(
          clientId: '',
          redirectUri: 'https://app.gewerber.de/auth/callback',
          operations: operations,
        ).isConfigured,
        isFalse,
      );
      expect(
        MicrosoftSocialAuthFlow(
          clientId: 'ms-client',
          redirectUri: '',
          operations: operations,
        ).isConfigured,
        isFalse,
      );
    });
  });
}

class _FakeGoogleOperations implements GoogleSignInOperations {
  _FakeGoogleOperations({this.result, this.error});

  final GoogleSignInResult? result;
  final Object? error;

  String? initializeClientId;
  String? initializeServerClientId;

  @override
  Future<void> initialize({String? clientId, String? serverClientId}) async {
    initializeClientId = clientId;
    initializeServerClientId = serverClientId;
  }

  @override
  Future<GoogleSignInResult> authenticate() async {
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

class _FakeAppleOperations implements AppleSignInOperations {
  _FakeAppleOperations({this.result, this.error});

  final AppleSignInResult? result;
  final Object? error;

  WebAuthenticationOptions? receivedWebOptions;

  @override
  Future<AppleSignInResult> getAppleIDCredential({
    required bool isWeb,
    String? clientId,
    Uri? redirectUri,
  }) async {
    receivedWebOptions = isWeb && clientId != null && redirectUri != null
        ? WebAuthenticationOptions(clientId: clientId, redirectUri: redirectUri)
        : null;
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

class _FakeFacebookOperations implements FacebookAuthOperations {
  _FakeFacebookOperations({required this.result});

  final LoginResult result;

  int initializeCalls = 0;
  String? lastInitializedAppId;
  String? lastInitializedVersion;
  bool? lastLoginWasWeb;

  @override
  Future<void> webAndDesktopInitialize({
    required String appId,
    required bool cookie,
    required bool xfbml,
    required String version,
  }) async {
    initializeCalls++;
    lastInitializedAppId = appId;
    lastInitializedVersion = version;
  }

  @override
  Future<LoginResult> login({required bool isWeb}) async {
    lastLoginWasWeb = isWeb;
    return result;
  }
}

class _FakeWebAuthOperations implements WebAuthenticationOperations {
  _FakeWebAuthOperations({this.callbackUrl, this.error});

  final String? callbackUrl;
  final Object? error;

  String? lastUrl;
  String? lastCallbackUrlScheme;
  String? lastHttpsHost;
  String? lastHttpsPath;

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    String? httpsHost,
    String? httpsPath,
  }) async {
    lastUrl = url;
    lastCallbackUrlScheme = callbackUrlScheme;
    lastHttpsHost = httpsHost;
    lastHttpsPath = httpsPath;
    if (error != null) {
      throw error!;
    }
    // Echo the state back so the happy-path assertions stay honest.
    if (callbackUrl == null) {
      return '';
    }
    final parsed = Uri.parse(callbackUrl!);
    final state = Uri.parse(url).queryParameters['state'];
    if (parsed.queryParameters.containsKey('state') &&
        parsed.queryParameters['state'] != state) {
      return callbackUrl!;
    }
    return parsed
        .replace(
          queryParameters: {
            ...parsed.queryParameters,
            if (!parsed.queryParameters.containsKey('code'))
              'code': 'auth-code',
            'state': state ?? '',
          },
        )
        .toString();
  }
}

LoginResult _loginResult(LoginStatus status, String? token, {String? message}) {
  return LoginResult(
    status: status,
    message: message,
    accessToken: token == null ? null : _FakeAccessToken(tokenString: token),
  );
}

class _FakeAccessToken extends AccessToken {
  _FakeAccessToken({required super.tokenString})
    : super(type: AccessTokenType.classic);

  @override
  Map<String, dynamic> toJson() => {'tokenString': tokenString};
}
