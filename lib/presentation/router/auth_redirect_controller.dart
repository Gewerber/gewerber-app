import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';

/// Bridges [AuthCubit] state changes into GoRouter's `refreshListenable`.
///
/// The GoRouter redirect reads [status] on every navigation; this controller
/// makes the router re-evaluate the current location whenever the auth state
/// changes, so protected routes are protected and auth routes are skipped for
/// signed-in users.
@LazySingleton()
class AuthRedirectController extends ChangeNotifier {
  AuthRedirectController(this._cubit) {
    _subscription = _cubit.stream.listen((_) => notifyListeners());
  }

  final AuthCubit _cubit;
  late final StreamSubscription<AuthState> _subscription;

  /// The current authentication status, mirroring the [AuthCubit] state.
  AuthStatus get status => _cubit.state.status;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
