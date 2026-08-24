import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/user_profile/user_profile_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/repositories/user_profile_repository.dart';

/// Owns the signed-in user's editable profile.
@LazySingleton()
class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit(this._repository) : super(const UserProfileState());

  final UserProfileRepository _repository;

  /// Loads the profile of the signed-in user.
  Future<void> load() async {
    emit(
      state.copyWith(status: UserProfileViewStatus.loading, clearFailure: true),
    );
    try {
      final profile = await _repository.get();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: UserProfileViewStatus.loaded,
          profile: profile,
          clearFailure: true,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: UserProfileViewStatus.failure,
          failure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(state.copyWith(status: UserProfileViewStatus.failure));
    }
  }

  /// Persists the given display name.
  ///
  /// Returns `true` on success.
  Future<bool> saveDisplayName(String? displayName) async {
    final normalized = displayName?.trim();
    final value = (normalized == null || normalized.isEmpty)
        ? null
        : normalized;
    emit(state.copyWith(isSaving: true, clearFailure: true));
    try {
      final updated = await _repository.updateDisplayName(value);
      if (!isClosed) {
        emit(
          state.copyWith(profile: updated, isSaving: false, clearFailure: true),
        );
      }
      return true;
    } on AccountDeletedException {
      // Surface through [UserProfileState.failure] so the app-level
      // "account deleted" handler can react.
      if (!isClosed) {
        emit(
          state.copyWith(
            isSaving: false,
            failure: const AccountDeletedFailure(),
          ),
        );
      }
      return false;
    } on Exception {
      if (!isClosed) emit(state.copyWith(isSaving: false));
      return false;
    }
  }

  /// Permanently deletes the signed-in account.
  ///
  /// Returns `true` when the account no longer exists on the server; callers
  /// proceed with the local sign-out in that case. On failure the user stays
  /// signed in and may retry.
  Future<bool> deleteAccount() async {
    emit(state.copyWith(isDeleting: true, clearFailure: true));
    try {
      await _repository.deleteAccount();
      if (!isClosed) emit(state.copyWith(isDeleting: false));
      return true;
    } on Exception {
      if (!isClosed) emit(state.copyWith(isDeleting: false));
      return false;
    }
  }

  /// Resets to the initial state.
  ///
  /// Used when the session ends so no data leaks across accounts.
  void reset() {
    emit(const UserProfileState());
  }
}
