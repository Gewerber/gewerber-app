import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';

/// The password-reset step the user is currently on.
enum ForgotPasswordStep { email, code, password, completed }

/// Immutable password-reset state.
class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    required this.step,
    this.email,
    this.isSubmitting = false,
    this.failure,
  });

  /// Initial state: user has not submitted an email yet.
  static const ForgotPasswordState initial = ForgotPasswordState(
    step: ForgotPasswordStep.email,
  );

  final ForgotPasswordStep step;

  /// The email address the reset applies to, used in step subtitles.
  final String? email;

  final bool isSubmitting;

  final Failure? failure;

  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    String? email,
    bool? isSubmitting,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      email: email ?? this.email,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [step, email, isSubmitting, failure];
}
