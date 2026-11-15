import 'package:flutter_test/flutter_test.dart';
import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import 'package:gewerber_app/core/config/app_config.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/user.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/domain/value_objects/password.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';
import 'package:gewerber_app/infrastructure/datasources/local/session_store.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/auth_remote_data_source.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social_auth_remote_data_source.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/user_profile_remote_data_source.dart';
import 'package:gewerber_app/infrastructure/mappers/user_mapper.dart';
import 'package:gewerber_app/infrastructure/repositories/serverpod_auth_repository.dart';

/// In-memory [ClientAuthSuccessStorage] so `client.auth.updateSignedInUser`
/// works without a platform channel.
class _Storage implements ClientAuthSuccessStorage {
  AuthSuccess? value;

  @override
  Future<AuthSuccess?> get() async => value;

  @override
  Future<void> set(AuthSuccess? data) async => value = data;
}

/// Replaces the generated client's transport: every call is recorded and
/// answered with a canned result or a thrown error.
class _FakeClient extends sdk.Client {
  _FakeClient() : super('http://localhost:8080') {
    storage = _Storage();
    authSessionManager = FlutterAuthSessionManager(storage: storage);
  }

  late final _Storage storage;

  final List<({String endpoint, String method, Map<String, dynamic> args})>
  calls = [];

  /// Answers `userProfile.me()` with this identity.
  sdk.MyIdentity identity = _identity();

  /// When set, the next endpoint call throws it.
  Object? error;

  /// When set, `userProfile.me()` throws a transport error.
  bool failProfile = false;

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    if (error != null) {
      throw error!;
    }
    if (failProfile && endpoint == 'userProfile') {
      throw const ServerpodClientNetworkException('down');
    }
    calls.add((endpoint: endpoint, method: method, args: args));
    if (T == sdk.MyIdentity) return identity as T;
    if (T == AuthSuccess) return _success() as T;
    throw StateError('unexpected $T');
  }
}

sdk.MyIdentity _identity({String? primaryEmail}) => sdk.MyIdentity(
  userId: sdk.UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
  memberships: const [],
  primaryEmail: primaryEmail,
  connectedProviders: const [sdk.AuthProvider.google],
);

AuthSuccess _success() => AuthSuccess(
  authUserId: sdk.UuidValue.fromString('00000000-0000-0000-0000-000000000002'),
  token: 'token',
  authStrategy: 'test',
  scopeNames: const {},
);

class _Factory extends ServerpodClientFactory {
  _Factory(this._fake) : super(AppConfig.fromFlavor());

  final _FakeClient _fake;

  @override
  sdk.Client get client => _fake;

  /// Session restore is the session manager's job (secure storage + server
  /// validation), not the repository's; the tests seed `authInfo` directly.
  @override
  Future<void> initialize() async {}
}

/// Returns a fixed credential regardless of the provider, so the repository's
/// dispatch to the transport can be asserted per provider.
class _FakeSocialDataSource extends SocialAuthRemoteDataSource {
  const _FakeSocialDataSource(this.credential);

  final SocialCredential credential;

  @override
  Future<SocialCredential> signIn(SocialAuthProvider provider) async =>
      credential;
}

/// Captures what the repository persists instead of touching
/// `SharedPreferences`.
class _FakeSessionStore extends SessionStore {
  User? written;
  int clears = 0;

  @override
  Future<User?> readUser() async => written;

  @override
  Future<void> writeUser(User user) async => written = user;

  @override
  Future<void> clear() async {
    written = null;
    clears++;
  }
}

void main() {
  late _FakeClient client;
  late ServerpodAuthRepository repository;
  late _FakeSessionStore sessionStore;

  ServerpodAuthRepository build({
    SocialCredential? credential,
    String? primaryEmail,
    Object? error,
  }) {
    client
      ..calls.clear()
      ..error = error
      ..failProfile = false
      ..identity = _identity(primaryEmail: primaryEmail);
    sessionStore = _FakeSessionStore();
    final factory = _Factory(client);
    return ServerpodAuthRepository(
      AuthRemoteDataSource(factory, UserProfileRemoteDataSource(factory)),
      _FakeSocialDataSource(
        credential ?? const GoogleCredential(idToken: 'google-id'),
      ),
      sessionStore,
      const UserMapper(),
    );
  }

  setUp(() {
    client = _FakeClient();
    repository = build();
  });

  String endpoints() =>
      client.calls.map((c) => '${c.endpoint}.${c.method}').join(',');

  group('socialLogin dispatch', () {
    test('google forwards the ID token and the access token', () async {
      repository = build(
        credential: const GoogleCredential(
          idToken: 'google-id',
          accessToken: 'google-access',
        ),
        primaryEmail: 'g@example.com',
      );

      final user = await repository.socialLogin(SocialAuthProvider.google);

      expect(endpoints(), 'googleIdp.login,userProfile.me');
      final args = client.calls.first.args;
      expect(args['idToken'], 'google-id');
      expect(args['accessToken'], 'google-access');
      expect(user.email, 'g@example.com');
    });

    test('google forwards the web PKCE code exchange', () async {
      repository = build(
        credential: const GoogleCodeCredential(
          code: 'google-code',
          codeVerifier: 'google-verifier',
          redirectUri: 'https://app.gewerber.de/auth.html',
        ),
        primaryEmail: 'g@example.com',
      );

      await repository.socialLogin(SocialAuthProvider.google);

      expect(endpoints(), 'googleIdp.loginWithCode,userProfile.me');
      final args = client.calls.first.args;
      expect(args['code'], 'google-code');
      expect(args['codeVerifier'], 'google-verifier');
      expect(args['redirectUri'], 'https://app.gewerber.de/auth.html');
    });

    test('apple forwards the identity token and the platform flag', () async {
      repository = build(
        credential: const AppleCredential(
          identityToken: 'apple-id',
          authorizationCode: 'apple-code',
          isNativeApplePlatformSignIn: true,
          firstName: 'Ada',
          lastName: 'Lovelace',
        ),
        primaryEmail: 'a@example.com',
      );

      await repository.socialLogin(SocialAuthProvider.apple);

      expect(endpoints(), 'appleIdp.login,userProfile.me');
      final args = client.calls.first.args;
      expect(args['identityToken'], 'apple-id');
      expect(args['authorizationCode'], 'apple-code');
      expect(args['isNativeApplePlatformSignIn'], isTrue);
      expect(args['firstName'], 'Ada');
      expect(args['lastName'], 'Lovelace');
    });

    test('facebook forwards the access token', () async {
      repository = build(
        credential: const FacebookCredential(accessToken: 'fb-token'),
        primaryEmail: 'f@example.com',
      );

      await repository.socialLogin(SocialAuthProvider.facebook);

      expect(endpoints(), 'facebookIdp.login,userProfile.me');
      expect(client.calls.first.args['accessToken'], 'fb-token');
    });

    test('microsoft forwards the PKCE code exchange', () async {
      repository = build(
        credential: const MicrosoftCredential(
          code: 'ms-code',
          codeVerifier: 'ms-verifier',
          redirectUri: 'https://app.gewerber.de/auth/callback',
          isWebPlatform: true,
        ),
        primaryEmail: 'm@example.com',
      );

      await repository.socialLogin(SocialAuthProvider.microsoft);

      expect(endpoints(), 'microsoftIdp.login,userProfile.me');
      final args = client.calls.first.args;
      expect(args['code'], 'ms-code');
      expect(args['codeVerifier'], 'ms-verifier');
      expect(args['redirectUri'], 'https://app.gewerber.de/auth/callback');
      expect(args['isWebPlatform'], isTrue);
    });
  });

  group('socialLogin profile mapping', () {
    test('persists the primary email reported by userProfile.me()', () async {
      repository = build(primaryEmail: 'resolved@example.com');

      final user = await repository.socialLogin(SocialAuthProvider.google);

      expect(user.email, 'resolved@example.com');
      expect(sessionStore.written?.email, 'resolved@example.com');
    });

    test('maps a missing email to an empty address', () async {
      repository = build(primaryEmail: null);

      final user = await repository.socialLogin(SocialAuthProvider.google);

      expect(user.email, isEmpty);
      expect(sessionStore.written, isNotNull);
    });
  });

  group('socialLogin profile read', () {
    test('keeps the session when the profile read fails', () async {
      repository = build(primaryEmail: 'ignored@example.com');
      // Fail only `userProfile.me()`, after the provider exchange succeeded.
      client.failProfile = true;

      final user = await repository.socialLogin(SocialAuthProvider.google);

      expect(user.email, isEmpty);
      expect(sessionStore.written, isNotNull);
      expect(client.auth.authInfo, isNotNull);
    });
  });

  group('socialLogin error mapping', () {
    test('a blocked account maps to UserBlockedException', () async {
      repository = build(error: AuthUserBlockedException());

      await expectLater(
        repository.socialLogin(SocialAuthProvider.google),
        throwsA(isA<UserBlockedException>()),
      );
      expect(sessionStore.written, isNull);
    });

    test(
      'a disabled provider (500) maps to the not-configured exception',
      () async {
        // The backend registers every IdP endpoint and only fails when the
        // provider lookup inside it finds nothing configured, which Serverpod
        // reports as a 500. (A 404 from an older deployment is mapped too.)
        repository = build(error: ServerpodClientInternalServerError());

        await expectLater(
          repository.socialLogin(SocialAuthProvider.google),
          throwsA(isA<SocialAuthNotConfiguredException>()),
        );
      },
    );

    test('an unverifiable Google token maps to a social failure', () async {
      repository = build(error: GoogleIdTokenVerificationException());

      await expectLater(
        repository.socialLogin(SocialAuthProvider.google),
        throwsA(isA<SocialAuthFailureException>()),
      );
    });

    test('an unverifiable Facebook token maps to a social failure', () async {
      repository = build(error: FacebookAccessTokenVerificationException());

      await expectLater(
        repository.socialLogin(SocialAuthProvider.facebook),
        throwsA(isA<SocialAuthFailureException>()),
      );
    });

    test('an unverifiable Microsoft token maps to a social failure', () async {
      repository = build(error: MicrosoftAccessTokenVerificationException());

      await expectLater(
        repository.socialLogin(SocialAuthProvider.microsoft),
        throwsA(isA<SocialAuthFailureException>()),
      );
    });

    test('a transport failure maps to NetworkException', () async {
      repository = build(error: const ServerpodClientNetworkException('down'));

      await expectLater(
        repository.socialLogin(SocialAuthProvider.google),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('finishRegistration email', () {
    test('takes the address from userProfile.me()', () async {
      repository = build(primaryEmail: 'new@example.com');

      final user = await repository.finishRegistration(
        registrationToken: 'token',
        password: Password('password123'),
      );

      expect(user.email, 'new@example.com');
      expect(endpoints(), contains('userProfile.me'));
    });
  });

  group('restoreSession email', () {
    test(
      'resolves the email from the backend when nothing is stored',
      () async {
        repository = build(primaryEmail: 'restored@example.com');
        // Seed the persisted session the session manager would have restored.
        await client.auth.updateSignedInUser(_success());

        final user = await repository.restoreSession();

        expect(user, isNotNull);
        expect(user!.email, 'restored@example.com');
        expect(sessionStore.written?.email, 'restored@example.com');
      },
    );

    test('keeps the stored address and repairs nothing', () async {
      repository = build(primaryEmail: 'server@example.com');
      sessionStore.written = const User(
        id: 'stored',
        email: 'stored@example.com',
      );
      await client.auth.updateSignedInUser(_success());

      final user = await repository.restoreSession();

      expect(user?.email, 'stored@example.com');
      expect(endpoints(), 'userProfile.me');
    });

    test('repairs an empty stored address on the next restore', () async {
      repository = build(primaryEmail: 'repaired@example.com');
      await client.auth.updateSignedInUser(_success());
      // A previous run persisted the session while `me()` was failing.
      sessionStore.written = const User(
        id: '00000000-0000-0000-0000-000000000002',
        email: '',
      );

      final user = await repository.restoreSession();

      expect(user?.email, 'repaired@example.com');
      expect(sessionStore.written?.email, 'repaired@example.com');
    });

    test('does not overwrite a stored address with an empty one', () async {
      repository = build(primaryEmail: null);
      await client.auth.updateSignedInUser(_success());
      sessionStore.written = const User(
        id: '00000000-0000-0000-0000-000000000002',
        email: 'kept@example.com',
      );

      final user = await repository.restoreSession();

      expect(user?.email, 'kept@example.com');
    });

    test('prefers the locally stored user', () async {
      repository = build(primaryEmail: 'server@example.com');
      await client.auth.updateSignedInUser(_success());
      sessionStore.written = const User(
        id: 'stored',
        email: 'stored@example.com',
      );

      final user = await repository.restoreSession();

      expect(user?.email, 'stored@example.com');
    });
  });

  test('login still uses the email endpoint and the given address', () async {
    repository = build(primaryEmail: 'server@example.com');

    final user = await repository.login(
      email: Email('someone@example.com'),
      password: Password('password123'),
    );

    expect(endpoints(), 'emailIdp.login');
    expect(user.email, 'someone@example.com');
  });
}
