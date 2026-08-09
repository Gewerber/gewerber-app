import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/user.dart';

/// Whether the current session is known, signed out, or active.
enum AuthStatus { unknown, unauthenticated, authenticated }

/// Immutable authentication state.
class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.user,
    this.isSubmitting = false,
    this.failure,
  });

  /// Initial state before any session lookup has run.
  static const AuthState unknown = AuthState(status: AuthStatus.unknown);

  final AuthStatus status;
  final User? user;
  final bool isSubmitting;
  final Failure? failure;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool clearUser = false,
    bool? isSubmitting,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, user, isSubmitting, failure];
}
