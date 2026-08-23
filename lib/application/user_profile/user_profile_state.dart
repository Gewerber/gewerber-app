import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/user_profile.dart';

/// Loading state of the user profile screen.
enum UserProfileViewStatus { initial, loading, loaded, failure }

/// Immutable user-profile state.
class UserProfileState extends Equatable {
  const UserProfileState({
    this.status = UserProfileViewStatus.initial,
    this.profile,
    this.isSaving = false,
    this.isDeleting = false,
    this.failure,
  });

  final UserProfileViewStatus status;

  /// `null` until the profile has been loaded from the server.
  final UserProfile? profile;

  /// Whether a save request is currently in flight.
  final bool isSaving;

  /// Whether an account-deletion request is currently in flight.
  final bool isDeleting;

  final Failure? failure;

  UserProfileState copyWith({
    UserProfileViewStatus? status,
    UserProfile? profile,
    bool? isSaving,
    bool? isDeleting,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, profile, isSaving, isDeleting, failure];
}
