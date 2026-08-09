import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/repositories/auth_repository.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';

/// Owns the authentication session.
///
/// Drives [AuthState] from startup (session restore) through sign-in and
/// sign-out, delegating to the injected [AuthRepository].
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(AuthState.unknown);

  final AuthRepository _repository;

  /// Restores a persisted session during startup.
  Future<void> restoreSession() async {
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
    try {
      final user = await _repository.login(email: email, password: password);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on InvalidCredentialsException {
      emit(
        state.copyWith(
          isSubmitting: false,
          failure: const InvalidCredentialsFailure(),
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          isSubmitting: false,
          failure: const TooManyAttemptsFailure(),
        ),
      );
    }
  }

  /// Clears the current session.
  Future<void> logOut() async {
    await _repository.logOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
