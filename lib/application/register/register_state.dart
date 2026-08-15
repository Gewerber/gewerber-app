import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';

/// The registration step the user is currently on.
enum RegisterStep { email, code, password, completed }

/// Immutable registration state.
class RegisterState extends Equatable {
  const RegisterState({
    required this.step,
    this.email,
    this.isSubmitting = false,
    this.failure,
  });

  /// Initial state: user has not submitted an email yet.
  static const RegisterState initial = RegisterState(step: RegisterStep.email);

  final RegisterStep step;

  /// The email address being registered, used in step subtitles.
  final String? email;

  final bool isSubmitting;

  final Failure? failure;

  RegisterState copyWith({
    RegisterStep? step,
    String? email,
    bool? isSubmitting,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return RegisterState(
      step: step ?? this.step,
      email: email ?? this.email,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [step, email, isSubmitting, failure];
}
