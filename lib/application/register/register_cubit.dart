import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/register/register_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/repositories/auth_repository.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/domain/value_objects/password.dart';
import 'package:gewerber_app/domain/value_objects/verification_code.dart';

/// Drives the three-step registration flow: email → verification code →
/// password.
///
/// On the final step the account is created server-side and the session is
/// already established; the [AuthCubit] is notified so the app becomes
/// authenticated.
@injectable
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._repository, this._authCubit)
    : super(RegisterState.initial);

  final AuthRepository _repository;
  final AuthCubit _authCubit;

  String? _accountRequestId;
  String? _registrationToken;

  /// Requests a verification code for [email].
  Future<void> submitEmail(String email) async {
    emit(state.copyWith(isSubmitting: true, clearFailure: true));
    final Email emailValue;
    try {
      emailValue = Email(email);
    } on FormatException {
      emit(
        state.copyWith(isSubmitting: false, failure: const ValidationFailure()),
      );
      return;
    }

    try {
      _accountRequestId = await _repository.startRegistration(
        email: emailValue,
      );
      emit(
        state.copyWith(
          step: RegisterStep.code,
          email: emailValue.value,
          isSubmitting: false,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(isSubmitting: false, failure: mapAppException(e)));
    } on Exception {
      emit(
        state.copyWith(isSubmitting: false, failure: const NetworkFailure()),
      );
    }
  }

  /// Verifies [code] and moves to the password step on success.
  Future<void> submitCode(String code) async {
    emit(state.copyWith(isSubmitting: true, clearFailure: true));
    final VerificationCode codeValue;
    try {
      codeValue = VerificationCode(code);
    } on FormatException {
      emit(
        state.copyWith(isSubmitting: false, failure: const ValidationFailure()),
      );
      return;
    }

    try {
      _registrationToken = await _repository.verifyRegistrationCode(
        accountRequestId: _accountRequestId!,
        code: codeValue,
      );
      emit(state.copyWith(step: RegisterStep.password, isSubmitting: false));
    } on AppException catch (e) {
      emit(state.copyWith(isSubmitting: false, failure: mapAppException(e)));
    } on Exception {
      emit(
        state.copyWith(isSubmitting: false, failure: const NetworkFailure()),
      );
    }
  }

  /// Creates the account with [password] and completes the flow.
  Future<void> submitPassword(String password) async {
    emit(state.copyWith(isSubmitting: true, clearFailure: true));
    final Password passwordValue;
    try {
      passwordValue = Password(password);
    } on FormatException {
      emit(
        state.copyWith(isSubmitting: false, failure: const ValidationFailure()),
      );
      return;
    }

    try {
      final user = await _repository.finishRegistration(
        registrationToken: _registrationToken!,
        password: passwordValue,
      );
      _authCubit.setAuthenticated(user);
      emit(state.copyWith(step: RegisterStep.completed, isSubmitting: false));
    } on AppException catch (e) {
      emit(state.copyWith(isSubmitting: false, failure: mapAppException(e)));
    } on Exception {
      emit(
        state.copyWith(isSubmitting: false, failure: const NetworkFailure()),
      );
    }
  }

  /// Moves back one step (no-op on the first step).
  void goBack() {
    if (state.step == RegisterStep.email) return;
    emit(
      state.copyWith(
        step: RegisterStep.values[state.step.index - 1],
        clearFailure: true,
      ),
    );
  }

  /// Resets the flow so the screen can be re-entered cleanly.
  void reset() {
    _accountRequestId = null;
    _registrationToken = null;
    emit(RegisterState.initial);
  }
}
