import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/user.dart';
import 'package:gewerber_app/domain/repositories/auth_repository.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/domain/value_objects/password.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';

/// Owns the authentication session.
///
/// Drives [AuthState] from startup (session restore) through sign-in and
/// sign-out, delegating to the injected [AuthRepository].
@LazySingleton()
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(AuthState.unknown);

  final AuthRepository _repository;

  /// Restores a persisted session during startup.
  Future<void> restoreSession() async {
    // Reset to the unknown state first so repeated restores (e.g. re-entering
    // the splash screen) always transition through the lookup state.
    emit(const AuthState(status: AuthStatus.unknown));
    try {
      final user = await _repository.restoreSession();
      emit(
        user != null
            ? AuthState(status: AuthStatus.authenticated, user: user)
            : const AuthState(status: AuthStatus.unauthenticated),
      );
    } on Exception {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  /// Attempts to sign the user in with the given credentials.
  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(isSubmitting: true, clearFailure: true));
    final Email emailValue;
    final Password passwordValue;
    try {
      emailValue = Email(email);
      passwordValue = Password(password);
    } on FormatException {
      emit(
        state.copyWith(isSubmitting: false, failure: const ValidationFailure()),
      );
      return;
    }

    try {
      final user = await _repository.login(
        email: emailValue,
        password: passwordValue,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AppException catch (e) {
      emit(state.copyWith(isSubmitting: false, failure: mapAppException(e)));
    } on Exception {
      emit(
        state.copyWith(isSubmitting: false, failure: const NetworkFailure()),
      );
    }
  }

  /// Attempts to sign the user in through a social identity provider.
  Future<void> socialLogin(SocialAuthProvider provider) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearFailure: true,
        submittingProvider: provider,
      ),
    );
    try {
      final user = await _repository.socialLogin(provider);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AppException catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          failure: mapAppException(e),
          clearSubmittingProvider: true,
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          isSubmitting: false,
          failure: const NetworkFailure(),
          clearSubmittingProvider: true,
        ),
      );
    }
  }

  /// Clears the current failure so inline error UI can be dismissed.
  void clearFailure() {
    emit(state.copyWith(clearFailure: true));
  }

  /// Marks the session as authenticated without a sign-in call.
  ///
  /// Used by flows that already established the session on the backend (e.g.
  /// account registration), so the router and the UI observe the new state.
  void setAuthenticated(User user) {
    emit(AuthState(status: AuthStatus.authenticated, user: user));
  }

  /// Resets to the initial unknown state.
  ///
  /// Used by tests to isolate scenarios from the shared singleton; the splash
  /// flow re-runs [restoreSession] afterwards.
  void reset() {
    emit(const AuthState(status: AuthStatus.unknown));
  }

  /// Clears the current session.
  ///
  /// Best-effort: even when the backend cannot be reached, the local session
  /// is cleared and the app returns to the login flow. A stale server session
  /// expires on its own.
  Future<void> logOut() async {
    try {
      await _repository.logOut();
    } on Exception {
      // The local session is authoritative for signing out; keep going so the
      // user is never left stuck in a half-signed-out state.
    }
    if (isClosed) return;
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
