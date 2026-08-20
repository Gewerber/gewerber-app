import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/forgot_password/forgot_password_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/repositories/auth_repository.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/domain/value_objects/password.dart';
import 'package:gewerber_app/domain/value_objects/verification_code.dart';

/// Drives the three-step password-reset flow: email → verification code →
/// new password.
@injectable
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._repository) : super(ForgotPasswordState.initial);

  final AuthRepository _repository;

  String? _passwordResetRequestId;
  String? _finishPasswordResetToken;

  /// Requests a password-reset code for [email].
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
      _passwordResetRequestId = await _repository.startPasswordReset(
        email: emailValue,
      );
      emit(
        state.copyWith(
          step: ForgotPasswordStep.code,
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

  /// Verifies [code] and moves to the new-password step on success.
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
      _finishPasswordResetToken = await _repository.verifyPasswordResetCode(
        passwordResetRequestId: _passwordResetRequestId!,
        code: codeValue,
      );
      emit(
        state.copyWith(step: ForgotPasswordStep.password, isSubmitting: false),
      );
    } on AppException catch (e) {
      emit(state.copyWith(isSubmitting: false, failure: mapAppException(e)));
    } on Exception {
      emit(
        state.copyWith(isSubmitting: false, failure: const NetworkFailure()),
      );
    }
  }

  /// Sets the new password and completes the flow.
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
      await _repository.finishPasswordReset(
        finishPasswordResetToken: _finishPasswordResetToken!,
        newPassword: passwordValue,
      );
      emit(
        state.copyWith(step: ForgotPasswordStep.completed, isSubmitting: false),
      );
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
    if (state.step == ForgotPasswordStep.email) return;
    emit(
      state.copyWith(
        step: ForgotPasswordStep.values[state.step.index - 1],
        clearFailure: true,
      ),
    );
  }

  /// Clears the current failure so inline error UI can be dismissed.
  void clearFailure() {
    emit(state.copyWith(clearFailure: true));
  }

  /// Resets the flow so the screen can be re-entered cleanly.
  void reset() {
    _passwordResetRequestId = null;
    _finishPasswordResetToken = null;
    emit(ForgotPasswordState.initial);
  }
}
